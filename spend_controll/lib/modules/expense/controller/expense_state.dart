part of 'expense_controller.dart';

enum ExpenseStatus { initial, loading, loaded, error, success }

class ExpenseState {
  final ExpenseStatus status;
  final List<Expense> expenses; // Lista de despesas do grupo selecionado
  final String? errorMessage;

  const ExpenseState({
    required this.status,
    this.expenses = const [],
    this.errorMessage,
  });

  const ExpenseState.initial()
      : this(
          status: ExpenseStatus.initial,
          expenses: const [],
          errorMessage: null,
        );

  ExpenseState copyWith({
    ExpenseStatus? status,
    List<Expense>? expenses,
    String? errorMessage,
    // Limpa a mensagem de erro se um novo status for definido sem erro
    bool clearErrorMessage = false,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
