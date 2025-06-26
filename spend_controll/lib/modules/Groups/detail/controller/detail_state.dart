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

  final ContributionStatus contributionStatus;
  final List<MemberContribution> memberContributions;
  final List<Expense> transactions;
  final List<Expense> filteredTransactions;
  final String? selectedMemberId;

  const DetailState({
    required this.status,
    required this.errorType,
    this.groups,
    this.errorMessage,
    this.contributionStatus = ContributionStatus.initial,
    this.memberContributions = const [],
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.selectedMemberId,
  });

  const DetailState.initial()
      : status = DetailStatus.initial,
        errorType = DetailErrorType.initial,
        groups = null,
        errorMessage = '',
        contributionStatus = ContributionStatus.initial,
        memberContributions = const [],
        transactions = const [],
        filteredTransactions = const [],
        selectedMemberId = null;

  List<Object?> get props => [
        status,
        errorMessage,
        errorType,
        groups,
        contributionStatus,
        memberContributions,
        transactions,
        filteredTransactions,
        selectedMemberId,
      ];

  DetailState copyWith({
    DetailStatus? status,
    String? errorMessage,
    Group? groups,
    DetailErrorType? errorType,
    ContributionStatus? contributionStatus,
    List<MemberContribution>? memberContributions,
    List<Expense>? transactions,
    List<Expense>? filteredTransactions,
    String? selectedMemberId,
  }) {
    return DetailState(
      status: status ?? this.status,
      errorType: errorType ?? this.errorType,
      groups: groups ?? this.groups,
      errorMessage: errorMessage ?? this.errorMessage,
      contributionStatus: contributionStatus ?? this.contributionStatus,
      memberContributions: memberContributions ?? this.memberContributions,
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      selectedMemberId: selectedMemberId ?? this.selectedMemberId,
    );
  }
}
