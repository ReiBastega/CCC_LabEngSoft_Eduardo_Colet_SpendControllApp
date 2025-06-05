import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spend_controll/modules/report/model/daily_total.dart';

import '../../transactions/model/group_model.dart';
import '../../transactions/model/transaction_model.dart';
import 'report_state.dart';

class ReportController extends ChangeNotifier {
  ReportState _state = ReportState.initial();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final ReportPdfGenerator _pdfGenerator = ReportPdfGenerator();

  ExportOptions _exportOptions = const ExportOptions(
    includeCharts: true,
    includeDetailedTable: true,
    includeInsights: true,
  );

  ReportState get state => _state;
  ExportOptions get exportOptions => _exportOptions;

  void _updateState(ReportState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadReportData() async {
    try {
      _updateState(_state.copyWith(isLoading: true, hasError: false));

      // Load available groups and categories for filtering
      await _loadGroups();
      await _loadCategories();

      // Load transactions for the selected period
      final transactions = await _fetchTransactions();

      // Process data for charts and insights
      final expensesByCategory = _calculateExpensesByCategory(transactions);
      final incomesByCategory = _calculateIncomesByCategory(transactions);
      final totalsByGroup = _calculateTotalsByGroup(transactions);
      final dailyTotals = _calculateDailyTotals(transactions);
      final monthlyComparison = await _calculateMonthlyComparison();

      // Calculate totals
      double totalIncome = 0;
      double totalExpense = 0;

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          totalExpense += transaction.amount;
        }
      }

      _updateState(_state.copyWith(
        isLoading: false,
        transactions: transactions,
        expensesByCategory: expensesByCategory,
        incomesByCategory: incomesByCategory,
        totalsByGroup: totalsByGroup,
        dailyTotals: dailyTotals,
        monthlyComparison: monthlyComparison,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<List<Transaction>> _fetchTransactions() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    // Build query based on filters
    Query query = _firestore.collection('transactions');

    // Apply user filter (only show user's transactions)
    query = query.where('userId', isEqualTo: user.uid);

    // Apply date range filter
    query = query.where('date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(_state.period.start));

    // Add one day to include the end date fully
    final endDatePlusOne = DateTime(
      _state.period.end.year,
      _state.period.end.month,
      _state.period.end.day + 1,
    );
    query = query.where('date', isLessThan: Timestamp.fromDate(endDatePlusOne));

    // Apply group filter if set
    if (_state.filter.groupIds != null && _state.filter.groupIds!.isNotEmpty) {
      query = query.where('groupId', whereIn: _state.filter.groupIds);
    }

    // Order by date
    query = query.orderBy('date', descending: true);

    // Execute query
    final querySnapshot = await query.get();

    // Convert to Transaction objects
    return querySnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // Skip transfers if not included in filter
          if (!_state.filter.includeTransfers &&
              _parseTransactionType(data['type']) == TransactionType.transfer) {
            return null;
          }

          // Skip categories not in filter if categories are specified
          if (_state.filter.categories != null &&
              _state.filter.categories!.isNotEmpty &&
              !_state.filter.categories!.contains(data['category'])) {
            return null;
          }

          return Transaction(
            id: doc.id,
            description: data['description'] ?? '',
            amount: (data['amount'] ?? 0).toDouble(),
            date: (data['date'] as Timestamp).toDate(),
            type: _parseTransactionType(data['type']),
            groupId: data['groupId'] ?? '',
            groupName: data['groupName'] ?? '',
          );
        })
        .where((transaction) => transaction != null)
        .cast<Transaction>()
        .toList();
  }

  Future<void> _loadGroups() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final groupsSnapshot = await _firestore
        .collection('groups')
        .where('members', arrayContains: user.uid)
        .get();

    final groups = groupsSnapshot.docs.map((doc) {
      final data = doc.data();
      return Group(
        id: doc.id,
        name: data['name'] ?? 'Sem nome',
      );
    }).toList();

    _updateState(_state.copyWith(availableGroups: groups));
  }

  Future<void> _loadCategories() async {
    final categories = [
      'Alimentação',
      'Transporte',
      'Moradia',
      'Lazer',
      'Saúde',
      'Educação',
      'Vestuário',
      'Outros',
    ];

    _updateState(_state.copyWith(availableCategories: categories));
  }

  Map<String, double> _calculateExpensesByCategory(
      List<Transaction> transactions) {
    final expensesByCategory = <String, double>{};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        final category = _getCategoryFromTransaction(transaction) ?? 'Outros';
        expensesByCategory[category] =
            (expensesByCategory[category] ?? 0) + transaction.amount;
      }
    }

    return expensesByCategory;
  }

  Map<String, double> _calculateIncomesByCategory(
      List<Transaction> transactions) {
    final incomesByCategory = <String, double>{};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        final category = _getCategoryFromTransaction(transaction) ?? 'Outros';
        incomesByCategory[category] =
            (incomesByCategory[category] ?? 0) + transaction.amount;
      }
    }

    return incomesByCategory;
  }

  Map<String, double> _calculateTotalsByGroup(List<Transaction> transactions) {
    final totalsByGroup = <String, double>{};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        totalsByGroup[transaction.groupName] =
            (totalsByGroup[transaction.groupName] ?? 0) - transaction.amount;
      } else if (transaction.type == TransactionType.income) {
        totalsByGroup[transaction.groupName] =
            (totalsByGroup[transaction.groupName] ?? 0) + transaction.amount;
      }
    }

    return totalsByGroup;
  }

  List<DailyTotal> _calculateDailyTotals(List<Transaction> transactions) {
    final dailyTotalsMap = <String, DailyTotal>{};

    for (final transaction in transactions) {
      final dateString = DateFormat('yyyy-MM-dd').format(transaction.date);

      if (!dailyTotalsMap.containsKey(dateString)) {
        dailyTotalsMap[dateString] = DailyTotal(
          date: DateTime(
            transaction.date.year,
            transaction.date.month,
            transaction.date.day,
          ),
          income: 0,
          expense: 0,
        );
      }

      if (transaction.type == TransactionType.income) {
        dailyTotalsMap[dateString] = DailyTotal(
          date: dailyTotalsMap[dateString]!.date,
          income: dailyTotalsMap[dateString]!.income + transaction.amount,
          expense: dailyTotalsMap[dateString]!.expense,
        );
      } else if (transaction.type == TransactionType.expense) {
        dailyTotalsMap[dateString] = DailyTotal(
          date: dailyTotalsMap[dateString]!.date,
          income: dailyTotalsMap[dateString]!.income,
          expense: dailyTotalsMap[dateString]!.expense + transaction.amount,
        );
      }
    }

    final dailyTotals = dailyTotalsMap.values.toList();
    dailyTotals.sort((a, b) => a.date.compareTo(b.date));

    return dailyTotals;
  }

  Future<List<MonthlyData>> _calculateMonthlyComparison() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

    final querySnapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(sixMonthsAgo))
        .get();

    final monthlyDataMap = <String, MonthlyData>{};

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final amount = (data['amount'] ?? 0).toDouble();
      final type = _parseTransactionType(data['type']);

      if (!monthlyDataMap.containsKey(monthKey)) {
        monthlyDataMap[monthKey] = MonthlyData(
          year: date.year,
          month: date.month,
          income: 0,
          expense: 0,
        );
      }

      if (type == TransactionType.income) {
        monthlyDataMap[monthKey] = MonthlyData(
          year: date.year,
          month: date.month,
          income: monthlyDataMap[monthKey]!.income + amount,
          expense: monthlyDataMap[monthKey]!.expense,
        );
      } else if (type == TransactionType.expense) {
        monthlyDataMap[monthKey] = MonthlyData(
          year: date.year,
          month: date.month,
          income: monthlyDataMap[monthKey]!.income,
          expense: monthlyDataMap[monthKey]!.expense + amount,
        );
      }
    }

    final monthlyData = monthlyDataMap.values.toList();
    monthlyData.sort((a, b) {
      if (a.year != b.year) {
        return a.year.compareTo(b.year);
      }
      return a.month.compareTo(b.month);
    });

    return monthlyData;
  }

  String? _getCategoryFromTransaction(Transaction transaction) {
    // In a real app, you would get the category from the transaction data
    // For this example, we'll return a random category
    final categories = _state.availableCategories;
    if (categories.isEmpty) {
      return null;
    }

    // Use the transaction ID to deterministically select a category
    final index = transaction.id.hashCode % categories.length;
    return categories[index.abs()];
  }

  TransactionType _parseTransactionType(String? typeStr) {
    switch (typeStr) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return TransactionType.expense; // Default to expense
    }
  }

  void setPeriod(DateTimeRange period) {
    _updateState(_state.copyWith(period: period));
    loadReportData();
  }

  void applyFilter(ReportFilter filter) {
    _updateState(_state.copyWith(filter: filter));
    loadReportData();
  }

  void setExportOption({
    bool? includeCharts,
    bool? includeDetailedTable,
    bool? includeInsights,
  }) {
    _exportOptions = ExportOptions(
      includeCharts: includeCharts ?? _exportOptions.includeCharts,
      includeDetailedTable:
          includeDetailedTable ?? _exportOptions.includeDetailedTable,
      includeInsights: includeInsights ?? _exportOptions.includeInsights,
    );
    notifyListeners();
  }

  // Future<bool> generatePdf() async {
  //   try {
  //     _updateState(_state.copyWith(isGeneratingPdf: true));

  //     final tempDir = await getTemporaryDirectory();
  //     final fileName = 'relatorio_financeiro_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
  //     final filePath = '${tempDir.path}/$fileName';

  //     await _pdfGenerator.generatePdf(
  //       filePath: filePath,
  //       state: _state,
  //       options: _exportOptions,
  //     );

  //     _updateState(_state.copyWith(
  //       isGeneratingPdf: false,
  //       pdfPath: filePath,
  //     ));

  //     return true;
  //   } catch (e) {
  //     _updateState(_state.copyWith(
  //       isGeneratingPdf: false,
  //       hasError: true,
  //       errorMessage: 'Erro ao gerar PDF: ${e.toString()}',
  //     ));

  //     return false;
  //   }
  // }

  Future<void> viewPdf() async {
    if (_state.pdfPath != null) {
      await OpenFile.open(_state.pdfPath!);
    }
  }

  Future<void> sharePdf() async {
    if (_state.pdfPath != null) {
      await Share.shareFiles(
        [_state.pdfPath!],
        text:
            'Relatório Financeiro - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
      );
    }
  }

  String getLargestExpense() {
    if (_state.transactions.isEmpty) {
      return 'Nenhuma despesa no período';
    }

    Transaction? largestExpense;

    for (final transaction in _state.transactions) {
      if (transaction.type == TransactionType.expense) {
        if (largestExpense == null ||
            transaction.amount > largestExpense.amount) {
          largestExpense = transaction;
        }
      }
    }

    if (largestExpense == null) {
      return 'Nenhuma despesa no período';
    }

    return '${largestExpense.description} - R\$ ${largestExpense.amount.toStringAsFixed(2)}';
  }

  String getLargestIncome() {
    if (_state.transactions.isEmpty) {
      return 'Nenhuma receita no período';
    }

    Transaction? largestIncome;

    for (final transaction in _state.transactions) {
      if (transaction.type == TransactionType.income) {
        if (largestIncome == null ||
            transaction.amount > largestIncome.amount) {
          largestIncome = transaction;
        }
      }
    }

    if (largestIncome == null) {
      return 'Nenhuma receita no período';
    }

    return '${largestIncome.description} - R\$ ${largestIncome.amount.toStringAsFixed(2)}';
  }

  String getMostExpensiveCategory() {
    if (_state.expensesByCategory.isEmpty) {
      return 'Nenhuma categoria no período';
    }

    String? mostExpensiveCategory;
    double highestAmount = 0;

    _state.expensesByCategory.forEach((category, amount) {
      if (amount > highestAmount) {
        mostExpensiveCategory = category;
        highestAmount = amount;
      }
    });

    if (mostExpensiveCategory == null) {
      return 'Nenhuma categoria no período';
    }

    return '$mostExpensiveCategory - R\$ ${highestAmount.toStringAsFixed(2)}';
  }
}

class ExportOptions {
  final bool includeCharts;
  final bool includeDetailedTable;
  final bool includeInsights;

  const ExportOptions({
    this.includeCharts = true,
    this.includeDetailedTable = true,
    this.includeInsights = true,
  });
}
