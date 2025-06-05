import 'package:flutter/material.dart';
import 'package:spend_controll/modules/report/model/daily_total.dart';

import '../../transactions/model/group_model.dart';
import '../../transactions/model/transaction_model.dart';

class ReportState {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final DateTimeRange period;
  final ReportFilter filter;
  final List<Transaction> transactions;
  final Map<String, double> expensesByCategory;
  final Map<String, double> incomesByCategory;
  final List<DailyTotal> dailyTotals;
  final Map<String, double> totalsByGroup;
  final List<MonthlyData> monthlyComparison;
  final double totalIncome;
  final double totalExpense;
  final bool isGeneratingPdf;
  final String? pdfPath;
  final List<Group> availableGroups;
  final List<String> availableCategories;

  const ReportState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    required this.period,
    this.filter = const ReportFilter(),
    this.transactions = const [],
    this.expensesByCategory = const {},
    this.incomesByCategory = const {},
    this.dailyTotals = const [],
    this.totalsByGroup = const {},
    this.monthlyComparison = const [],
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.isGeneratingPdf = false,
    this.pdfPath,
    this.availableGroups = const [],
    this.availableCategories = const [],
  });

  factory ReportState.initial() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return ReportState(
      period: DateTimeRange(
        start: firstDayOfMonth,
        end: lastDayOfMonth,
      ),
    );
  }

  ReportState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    DateTimeRange? period,
    ReportFilter? filter,
    List<Transaction>? transactions,
    Map<String, double>? expensesByCategory,
    Map<String, double>? incomesByCategory,
    List<DailyTotal>? dailyTotals,
    Map<String, double>? totalsByGroup,
    List<MonthlyData>? monthlyComparison,
    double? totalIncome,
    double? totalExpense,
    bool? isGeneratingPdf,
    String? pdfPath,
    List<Group>? availableGroups,
    List<String>? availableCategories,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      period: period ?? this.period,
      filter: filter ?? this.filter,
      transactions: transactions ?? this.transactions,
      expensesByCategory: expensesByCategory ?? this.expensesByCategory,
      incomesByCategory: incomesByCategory ?? this.incomesByCategory,
      dailyTotals: dailyTotals ?? this.dailyTotals,
      totalsByGroup: totalsByGroup ?? this.totalsByGroup,
      monthlyComparison: monthlyComparison ?? this.monthlyComparison,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      isGeneratingPdf: isGeneratingPdf ?? this.isGeneratingPdf,
      pdfPath: pdfPath ?? this.pdfPath,
      availableGroups: availableGroups ?? this.availableGroups,
      availableCategories: availableCategories ?? this.availableCategories,
    );
  }
}

class ReportFilter {
  final List<String>? groupIds;
  final List<String>? categories;
  final bool includeTransfers;
  final GroupingType groupingType;

  const ReportFilter({
    this.groupIds,
    this.categories,
    this.includeTransfers = true,
    this.groupingType = GroupingType.daily,
  });

  ReportFilter copyWith({
    List<String>? groupIds,
    List<String>? categories,
    bool? includeTransfers,
    GroupingType? groupingType,
  }) {
    return ReportFilter(
      groupIds: groupIds ?? this.groupIds,
      categories: categories ?? this.categories,
      includeTransfers: includeTransfers ?? this.includeTransfers,
      groupingType: groupingType ?? this.groupingType,
    );
  }
}

enum GroupingType { daily, weekly, monthly }

class MonthlyData {
  final int year;
  final int month;
  final double income;
  final double expense;

  MonthlyData({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
  });

  String get monthName {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Fev';
      case 3:
        return 'Mar';
      case 4:
        return 'Abr';
      case 5:
        return 'Mai';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Ago';
      case 9:
        return 'Set';
      case 10:
        return 'Out';
      case 11:
        return 'Nov';
      case 12:
        return 'Dez';
      default:
        return '';
    }
  }

  String get label => '$monthName/$year';

  double get balance => income - expense;
}
