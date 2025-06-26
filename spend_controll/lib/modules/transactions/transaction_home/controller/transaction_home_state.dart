import 'package:spend_controll/modules/transactions/model/group_model.dart';

import '../../model/transaction_model.dart';

class TransactionHomeState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String? errorMessage;
  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpense;
  final double totalTransfer;
  final TransactionFilter filter;
  final bool hasMoreTransactions;
  final List<Group> availableGroups;
  const TransactionHomeState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage,
    this.transactions = const [],
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.totalTransfer = 0,
    this.filter = const TransactionFilter(),
    this.hasMoreTransactions = false,
    this.availableGroups = const [],
  });

  factory TransactionHomeState.initial() => const TransactionHomeState();

  TransactionHomeState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    String? errorMessage,
    List<Transaction>? transactions,
    double? totalIncome,
    double? totalExpense,
    TransactionFilter? filter,
    bool? hasMoreTransactions,
    List<Group>? availableGroups,
    double? totalTransfer,
  }) {
    return TransactionHomeState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      transactions: transactions ?? this.transactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      filter: filter ?? this.filter,
      hasMoreTransactions: hasMoreTransactions ?? this.hasMoreTransactions,
      availableGroups: availableGroups ?? this.availableGroups,
      totalTransfer: totalTransfer ?? this.totalTransfer,
    );
  }
}

class TransactionFilter {
  final TransactionType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? groupId;
  final String? searchQuery;

  const TransactionFilter({
    this.type,
    this.startDate,
    this.endDate,
    this.groupId,
    this.searchQuery,
  });

  TransactionFilter copyWith({
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? groupId,
    String? searchQuery,
  }) {
    return TransactionFilter(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      groupId: groupId ?? this.groupId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
