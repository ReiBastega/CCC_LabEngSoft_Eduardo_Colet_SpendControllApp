import 'package:spend_controll/modules/transactions/add_expense/controller/add_expense_controller.dart';

enum AddExpenseStatus { initial, loading, failure, success }

class AddExpenseState {
  final AddExpenseStatus status;
  final bool isLoading;
  final bool isSaving;
  final bool hasError;
  final String? errorMessage;
  final List<Group> groups;

  const AddExpenseState({
    this.status = AddExpenseStatus.initial,
    this.isLoading = false,
    this.isSaving = false,
    this.hasError = false,
    this.errorMessage,
    this.groups = const [],
  });

  factory AddExpenseState.initial() => const AddExpenseState();

  AddExpenseState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? hasError,
    String? errorMessage,
    List<Group>? groups,
    AddExpenseStatus? status,
  }) {
    return AddExpenseState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      groups: groups ?? this.groups,
    );
  }
}
