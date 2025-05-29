import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/modules/transactions/model/transaction_model.dart';

enum HomeStatus { initial, loading, failure, success }

enum HomeErrorType {
  initial,
  network,
  authentication,
  unknown,
}

class HomeState {
  final HomeStatus status;
  final HomeErrorType errorType;
  final String? errorMessage;
  final bool isAuthenticated;
  final String? userName;
  final List<Group> groups;
  final List<Transaction> recentTransactions;
  final double totalBalance;
  final Map<String, double> monthlySummary;
  const HomeState({
    required this.errorType,
    required this.status,
    this.errorMessage,
    this.isAuthenticated = true,
    this.userName,
    this.groups = const [],
    this.recentTransactions = const [],
    this.totalBalance = 0.0,
    this.monthlySummary = const {},
  });

  const HomeState.initial()
      : this(
          status: HomeStatus.initial,
          errorMessage: '',
          groups: const [],
          recentTransactions: const [],
          totalBalance: 0.0,
          monthlySummary: const {},
          isAuthenticated: true,
          userName: '',
          errorType: HomeErrorType.initial,
        );

  List<Object?> get props => [
        status,
        errorMessage,
        isAuthenticated,
        userName,
        groups,
        recentTransactions,
        totalBalance,
        monthlySummary,
        errorType,
      ];

  HomeState copyWith({
    HomeStatus? status,
    String? errorMessege,
    String? errorMessage,
    bool? isAuthenticated,
    String? userName,
    List<Group>? groups,
    List<Transaction>? recentTransactions,
    double? totalBalance,
    Map<String, double>? monthlySummary,
    HomeErrorType? errorType,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userName: userName ?? this.userName,
      groups: groups ?? this.groups,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      totalBalance: totalBalance ?? this.totalBalance,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      errorType: errorType ?? this.errorType,
    );
  }
}
