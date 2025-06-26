import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/transactions/model/group_model.dart';
import 'package:spend_controll/modules/transactions/transaction_home/controller/transaction_home_state.dart';

import '../../model/transaction_model.dart';

class TransactionHomeController extends Cubit<TransactionHomeState>
    implements ChangeNotifier {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  TransactionHomeController({required this.auth, required this.firestore})
      : super(TransactionHomeState.initial());
  static const int _pageSize = 15;
  DocumentSnapshot? _lastDocument;

  Future<void> loadTransactions() async {
    try {
      emit(state.copyWith(isLoading: true, hasError: false));

      await _loadGroups();

      _lastDocument = null;

      final transactions = await _fetchTransactions();

      final totals = _calculateTotals(transactions);

      emit(state.copyWith(
        isLoading: false,
        transactions: transactions,
        totalIncome: totals.income,
        totalExpense: totals.expense,
        totalTransfer: totals.transfer,
        hasMoreTransactions: transactions.length >= _pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refreshTransactions() async {
    _lastDocument = null;

    try {
      final transactions = await _fetchTransactions();

      final totals = _calculateTotals(transactions);

      emit(state.copyWith(
        transactions: transactions,
        totalIncome: totals.income,
        totalExpense: totals.expense,
        totalTransfer: totals.transfer,
        hasMoreTransactions: transactions.length >= _pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        hasError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMoreTransactions() async {
    if (!state.hasMoreTransactions || state.isLoadingMore) {
      return;
    }

    try {
      emit(state.copyWith(isLoadingMore: true));

      final newTransactions = await _fetchTransactions(loadMore: true);

      final allTransactions = [...state.transactions, ...newTransactions];

      final totals = _calculateTotals(allTransactions);

      emit(state.copyWith(
        isLoadingMore: false,
        transactions: allTransactions,
        totalIncome: totals.income,
        totalExpense: totals.expense,
        totalTransfer: totals.transfer,
        hasMoreTransactions: newTransactions.length >= _pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        hasError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<List<Transaction>> _fetchTransactions({bool loadMore = false}) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    Query query = firestore.collection('transactions');

    query = query.where('userId', isEqualTo: user.uid);

    if (state.filter.type != null) {
      query = query.where('type',
          isEqualTo: state.filter.type.toString().split('.').last);
    }

    if (state.filter.groupId != null && state.filter.groupId!.isNotEmpty) {
      query = query.where('groupId', isEqualTo: state.filter.groupId);
    }

    if (state.filter.startDate != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(state.filter.startDate!));
    }

    if (state.filter.endDate != null) {
      final endDatePlusOne = DateTime(
        state.filter.endDate!.year,
        state.filter.endDate!.month,
        state.filter.endDate!.day + 1,
      );
      query =
          query.where('date', isLessThan: Timestamp.fromDate(endDatePlusOne));
    }

    query = query.orderBy('date', descending: true);

    if (loadMore && _lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    query = query.limit(_pageSize);

    final querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
    }

    return querySnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          if (state.filter.searchQuery != null &&
              state.filter.searchQuery!.isNotEmpty &&
              !data['description']
                  .toString()
                  .toLowerCase()
                  .contains(state.filter.searchQuery!.toLowerCase())) {
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
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final groupsSnapshot = await firestore
        .collection('groups')
        .where('memberUserIds', arrayContains: user.uid)
        .get();

    final groups = groupsSnapshot.docs.map((doc) {
      final data = doc.data();
      return Group(
        id: doc.id,
        name: data['name'] ?? 'Sem nome',
      );
    }).toList();

    emit(state.copyWith(availableGroups: groups));
  }

  _TransactionTotals _calculateTotals(List<Transaction> transactions) {
    double totalIncome = 0;
    double totalExpense = 0;
    double totalTransfer = 0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        totalExpense += transaction.amount;
      } else if (transaction.type == TransactionType.transfer) {
        totalTransfer += transaction.amount;
      }
    }

    return _TransactionTotals(
        income: totalIncome, expense: totalExpense, transfer: totalTransfer);
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
        return TransactionType.expense;
    }
  }

  void applyFilter(TransactionFilter filter) {
    emit(state.copyWith(filter: filter));
    loadTransactions();
  }

  void clearTypeFilter() {
    emit(state.copyWith(
      filter: state.filter.copyWith(type: null),
    ));
    loadTransactions();
  }

  void clearGroupFilter() {
    emit(state.copyWith(
      filter: state.filter.copyWith(groupId: null),
    ));
    loadTransactions();
  }

  void clearDateFilter() {
    emit(state.copyWith(
      filter: state.filter.copyWith(startDate: null, endDate: null),
    ));
    loadTransactions();
  }

  void clearSearchQuery() {
    emit(state.copyWith(
      filter: state.filter.copyWith(searchQuery: null),
    ));
    loadTransactions();
  }

  void clearAllFilters() {
    emit(state.copyWith(
      filter: const TransactionFilter(),
    ));
    loadTransactions();
  }

  void setSearchQuery(String query) {
    if (query.isEmpty) {
      clearSearchQuery();
      return;
    }

    emit(state.copyWith(
      filter: state.filter.copyWith(searchQuery: query),
    ));
    loadTransactions();
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    try {
      emit(state.copyWith(isLoading: true));

      await firestore.collection('transactions').doc(transaction.id).delete();

      if (transaction.type == TransactionType.income) {
        await firestore.collection('groups').doc(transaction.groupId).update({
          'balance': FieldValue.increment(-transaction.amount),
        });
      } else if (transaction.type == TransactionType.expense) {
        await firestore.collection('groups').doc(transaction.groupId).update({
          'balance': FieldValue.increment(transaction.amount),
        });
      } else if (transaction.type == TransactionType.transfer) {
        final transactionDoc = await firestore
            .collection('transactions')
            .doc(transaction.id)
            .get();
        final data = transactionDoc.data();

        if (data != null) {
          final sourceGroupId = data['sourceGroupId'];
          final destinationGroupId = data['destinationGroupId'];

          if (sourceGroupId != null) {
            await firestore.collection('groups').doc(sourceGroupId).update({
              'balance': FieldValue.increment(transaction.amount),
            });
          }

          if (destinationGroupId != null) {
            await firestore
                .collection('groups')
                .doc(destinationGroupId)
                .update({
              'balance': FieldValue.increment(-transaction.amount),
            });
          }
        }
      }

      await refreshTransactions();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Erro ao excluir transação: ${e.toString()}',
      ));
    }
  }

  @override
  void addListener(VoidCallback listener) {
    // TODO: implement addListener
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  // TODO: implement hasListeners
  bool get hasListeners => throw UnimplementedError();

  @override
  void notifyListeners() {
    // TODO: implement notifyListeners
  }

  @override
  void removeListener(VoidCallback listener) {
    // TODO: implement removeListener
  }
}

class _TransactionTotals {
  final double income;
  final double expense;
  final double transfer;

  _TransactionTotals({
    required this.income,
    required this.expense,
    required this.transfer,
  });
}
