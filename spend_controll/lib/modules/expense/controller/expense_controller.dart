import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spend_controll/modules/expense/expense_model.dart';
import 'package:spend_controll/modules/service/service.dart';

part 'expense_state.dart';

class ExpenseController extends Cubit<ExpenseState> {
  final Service service;
  StreamSubscription? _expensesSubscription;
  String? _currentGroupId;

  ExpenseController({required this.service})
      : super(const ExpenseState.initial());

  // Carrega as despesas de um grupo específico
  void loadGroupExpenses(String groupId) {
    if (groupId.isEmpty) {
      emit(state.copyWith(
          status: ExpenseStatus.error,
          errorMessage: "ID do grupo inválido.",
          clearErrorMessage: true));
      return;
    }
    // Se já estiver ouvindo o mesmo grupo, não faz nada
    if (_currentGroupId == groupId &&
        state.status != ExpenseStatus.initial &&
        state.status != ExpenseStatus.error) {
      return;
    }

    _currentGroupId = groupId;
    emit(
        state.copyWith(status: ExpenseStatus.loading, clearErrorMessage: true));
    _expensesSubscription?.cancel(); // Cancela inscrição anterior

    _expensesSubscription =
        service.getGroupExpenses(groupId).listen((expenses) {
      emit(state.copyWith(
          status: ExpenseStatus.loaded,
          expenses: expenses,
          clearErrorMessage: true));
    }, onError: (error) {
      emit(state.copyWith(
          status: ExpenseStatus.error,
          errorMessage: "Erro ao carregar despesas: ${error.toString()}"));
    });
  }

  // Adiciona uma nova despesa
  Future<void> addExpense(Expense expense) async {
    emit(
        state.copyWith(status: ExpenseStatus.loading, clearErrorMessage: true));
    try {
      await service.addExpense(expense);
      // O stream deve atualizar a lista, emitimos success para feedback
      emit(state.copyWith(
          status: ExpenseStatus.success, clearErrorMessage: true));
      // Não precisa recarregar explicitamente, o stream faz isso.
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: ExpenseStatus.error,
          errorMessage: "Erro de autenticação: ${e.message}"));
    } on Exception catch (e) {
      // Captura exceções gerais do Service (dados inválidos, etc)
      emit(state.copyWith(
          status: ExpenseStatus.error,
          errorMessage: "Erro ao adicionar despesa: ${e.toString()}"));
    } catch (e) {
      emit(state.copyWith(
          status: ExpenseStatus.error,
          errorMessage:
              "Erro inesperado ao adicionar despesa: ${e.toString()}"));
    }
  }

  // Atualiza uma despesa existente
  Future<void> updateExpense(Expense expense) async {
    emit(
        state.copyWith(status: ExpenseStatus.loading, clearErrorMessage: true));
    try {
      await service.updateExpense(expense);
      emit(state.copyWith(
          status: ExpenseStatus.success, clearErrorMessage: true));
      // Stream atualizará
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: ExpenseStatus.error,
          errorMessage: "Erro de autenticação: ${e.message}"));
    } on Exception catch (e) {
      emit(state.copyWith(
          status: ExpenseStatus.error,
          errorMessage: "Erro ao atualizar despesa: ${e.toString()}"));
    } catch (e) {
      emit(state.copyWith(
          status: ExpenseStatus.error,
          errorMessage:
              "Erro inesperado ao atualizar despesa: ${e.toString()}"));
    }
  }

  // Deleta uma despesa
  Future<void> deleteExpense(String groupId, String expenseId) async {
    emit(
        state.copyWith(status: ExpenseStatus.loading, clearErrorMessage: true));
    try {
      await service.deleteExpense(groupId, expenseId);
      emit(state.copyWith(
          status: ExpenseStatus.success, clearErrorMessage: true));
      // Stream atualizará
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: ExpenseStatus.error,
          errorMessage: "Erro de autenticação: ${e.message}"));
    } on Exception catch (e) {
      emit(state.copyWith(
          status: ExpenseStatus.error,
          errorMessage: "Erro ao excluir despesa: ${e.toString()}"));
    } catch (e) {
      emit(state.copyWith(
          status: ExpenseStatus.error,
          errorMessage: "Erro inesperado ao excluir despesa: ${e.toString()}"));
    }
  }

  // Limpa a inscrição do stream ao descartar o controller
  @override
  Future<void> close() {
    _expensesSubscription?.cancel();
    _currentGroupId = null;
    return super.close();
  }
}
