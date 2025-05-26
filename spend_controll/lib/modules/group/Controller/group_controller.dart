import 'dart:async'; // Import for StreamSubscription

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/group/Controller/group_state.dart';
import 'package:spend_controll/modules/service/service.dart';

class GroupController extends Cubit<GroupState> {
  final Service service;
  StreamSubscription? _groupsSubscription;

  GroupController({required this.service}) : super(const GroupState.initial()) {
    _loadUserGroups(); // Carrega os grupos ao iniciar o controller
  }

  // Carrega os grupos do usuário logado
  void _loadUserGroups() {
    emit(state.copyWith(status: GroupStatus.loading));
    _groupsSubscription?.cancel(); // Cancela inscrição anterior se houver
    _groupsSubscription = service.getUserGroups().listen((groups) {
      emit(state.copyWith(status: GroupStatus.loaded, groups: groups));
    }, onError: (error) {
      emit(state.copyWith(
          status: GroupStatus.error,
          errorMessage: "Erro ao carregar grupos: ${error.toString()}"));
    });
  }

  // Cria um novo grupo
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
      // O stream já vai atualizar a lista, mas podemos emitir success se quisermos feedback imediato
      emit(state.copyWith(status: GroupStatus.success));
      // Recarrega explicitamente ou confia no stream para atualizar
      // _loadUserGroups(); // Opcional: Forçar recarga ou esperar o stream
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

  // Adiciona usuário ao grupo (implementação pendente no Service)
  Future<void> addUserToGroup(String groupId, String userEmail) async {
    emit(state.copyWith(status: GroupStatus.loading));
    try {
      // TODO: Implementar busca de usuário por email no Service
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

  // Remove usuário do grupo
  Future<void> removeUserFromGroup(
      String groupId, String userIdToRemove) async {
    emit(state.copyWith(status: GroupStatus.loading));
    try {
      await service.removeUserFromGroup(groupId, userIdToRemove);
      emit(state.copyWith(status: GroupStatus.success));
      // O stream deve atualizar a lista de membros indiretamente se a view depender disso
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

  // Limpa a inscrição do stream ao descartar o controller
  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}
