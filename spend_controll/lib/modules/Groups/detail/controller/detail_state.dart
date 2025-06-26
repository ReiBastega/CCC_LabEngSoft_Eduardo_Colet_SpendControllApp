import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/modules/Groups/model/member_contribuition.dart';
import 'package:spend_controll/modules/expenses/expense/model/expense_model.dart';

enum DetailStatus { initial, loading, failure, success }

enum DetailErrorType { initial, network, authentication, unknown }

enum ContributionStatus { initial, loading, loaded, error }

class DetailState {
  final DetailStatus status;
  final DetailErrorType errorType;
  final Group? groups;
  final String? errorMessage;

  // Member contribution and expenses
  final ContributionStatus contributionStatus;
  final List<MemberContribution> memberContributions;
  final List<Expense> expenses;
  final List<Expense> filteredExpenses;
  final String? selectedMemberId;

  const DetailState({
    required this.status,
    required this.errorType,
    this.groups,
    this.errorMessage,
    this.contributionStatus = ContributionStatus.initial,
    this.memberContributions = const [],
    this.expenses = const [],
    this.filteredExpenses = const [],
    this.selectedMemberId,
  });

  const DetailState.initial()
      : status = DetailStatus.initial,
        errorType = DetailErrorType.initial,
        groups = null,
        errorMessage = '',
        contributionStatus = ContributionStatus.initial,
        memberContributions = const [],
        expenses = const [],
        filteredExpenses = const [],
        selectedMemberId = null;

  List<Object?> get props => [
        status,
        errorMessage,
        errorType,
        groups,
        contributionStatus,
        memberContributions,
        expenses,
        filteredExpenses,
        selectedMemberId,
      ];

  DetailState copyWith({
    DetailStatus? status,
    String? errorMessage,
    Group? groups,
    DetailErrorType? errorType,
    ContributionStatus? contributionStatus,
    List<MemberContribution>? memberContributions,
    List<Expense>? expenses,
    List<Expense>? filteredExpenses,
    String? selectedMemberId,
  }) {
    return DetailState(
      status: status ?? this.status,
      errorType: errorType ?? this.errorType,
      groups: groups ?? this.groups,
      errorMessage: errorMessage ?? this.errorMessage,
      contributionStatus: contributionStatus ?? this.contributionStatus,
      memberContributions: memberContributions ?? this.memberContributions,
      expenses: expenses ?? this.expenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      selectedMemberId: selectedMemberId ?? this.selectedMemberId,
    );
  }
}
