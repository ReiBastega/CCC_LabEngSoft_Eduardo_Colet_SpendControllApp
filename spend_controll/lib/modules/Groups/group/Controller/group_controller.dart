import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/Groups/group/Controller/group_state.dart';
import 'package:spend_controll/modules/service/service.dart';

class GroupController extends Cubit<GroupState> {
  final Service service;
  StreamSubscription? _groupsSubscription;

  GroupController({required this.service}) : super(const GroupState.initial()) {
    _loadUserGroups();
  }

  void _loadUserGroups() {
    emit(state.copyWith(status: GroupStatus.loading));
    _groupsSubscription?.cancel();
    _groupsSubscription = service.getUserGroups().listen((groups) {
      emit(state.copyWith(status: GroupStatus.loaded, groups: groups));
    }, onError: (error) {
      emit(state.copyWith(
          status: GroupStatus.error,
          errorMessage: "Erro ao carregar grupos: ${error.toString()}"));
    });
  }

  Future<void> createGroup(String groupName) async {
    if (groupName.trim().isEmpty) {
      emit(state.copyWith(
          status: GroupStatus.error,
          errorMessage: "Nome do grupo não pode ser vazio."));
      return;
    }
    emit(state.copyWith(status: GroupStatus.loading));
    try {
      await service.createGroup(groupName);
      emit(state.copyWith(status: GroupStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: GroupStatus.error,
          errorMessage: "Erro de autenticação: ${e.message}"));
    } catch (e) {
      emit(state.copyWith(
          status: GroupStatus.error,
          errorMessage: "Erro ao criar grupo: ${e.toString()}"));
    }
  }

  Future<void> addUserToGroup(String groupId, String userEmail) async {
    emit(state.copyWith(status: GroupStatus.loading));
    try {
      await service.addUserToGroup(groupId, userEmail);
      emit(state.copyWith(status: GroupStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: GroupStatus.error,
          errorMessage: "Erro de autenticação: ${e.message}"));
    } on UnimplementedError catch (e) {
      emit(state.copyWith(
          status: GroupStatus.error,
          errorMessage: "Funcionalidade pendente: ${e.message}"));
    } catch (e) {
      emit(state.copyWith(
          status: GroupStatus.error,
          errorMessage: "Erro ao adicionar usuário: ${e.toString()}"));
    }
  }

  Future<void> deleteGroup(String groupId) async {
    emit(state.copyWith(status: GroupStatus.loading));
    try {
      await service.deleteGroup(groupId);
      emit(state.copyWith(status: GroupStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: GroupStatus.error,
        errorMessage: "Erro ao excluir grupo: ${e.toString()}",
      ));
    }
  }

  Future<void> removeUserFromGroup(
      String groupId, String userIdToRemove) async {
    emit(state.copyWith(status: GroupStatus.loading));
    try {
      await service.removeUserFromGroup(groupId, userIdToRemove);
      emit(state.copyWith(status: GroupStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: GroupStatus.error,
          errorMessage: "Erro de autenticação: ${e.message}"));
    } catch (e) {
      emit(state.copyWith(
          status: GroupStatus.error,
          errorMessage: "Erro ao remover usuário: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}
