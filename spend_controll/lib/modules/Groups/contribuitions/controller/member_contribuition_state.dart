// Estado do controller
import 'package:spend_controll/modules/Groups/model/member_contribuition.dart';
import 'package:spend_controll/modules/expenses/expense/model/expense_model.dart';

enum ContributionStatus { initial, loading, loaded, error }

class MemberContributionState {
  final ContributionStatus status;
  final List<MemberContribution> memberContributions;
  final List<Expense> expenses;
  final List<Expense> filteredExpenses;
  final String? selectedMemberId;
  final String? errorMessage;

  const MemberContributionState({
    required this.status,
    required this.memberContributions,
    required this.expenses,
    required this.filteredExpenses,
    this.selectedMemberId,
    this.errorMessage,
  });

  const MemberContributionState.initial()
      : status = ContributionStatus.initial,
        memberContributions = const [],
        expenses = const [],
        filteredExpenses = const [],
        selectedMemberId = null,
        errorMessage = null;

  MemberContributionState copyWith({
    ContributionStatus? status,
    List<MemberContribution>? memberContributions,
    List<Expense>? expenses,
    List<Expense>? filteredExpenses,
    String? selectedMemberId,
    String? errorMessage,
  }) {
    return MemberContributionState(
      status: status ?? this.status,
      memberContributions: memberContributions ?? this.memberContributions,
      expenses: expenses ?? this.expenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      selectedMemberId: selectedMemberId,
      errorMessage: errorMessage,
    );
  }
}
