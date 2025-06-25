import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/Groups/invite/controller/group_invite_state.dart';
import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/modules/service/service.dart';
import 'package:spend_controll/modules/service/service_extension.dart';

class GroupInviteController extends Cubit<GroupInviteState> {
  final Service service;
  final String groupId;
  final Group group;

  GroupInviteController({
    required this.service,
    required this.groupId,
    required this.group,
  }) : super(const GroupInviteState.initial());

  Future<void> searchUserByEmail(String email) async {
    if (email.trim().isEmpty) {
      emit(state.copyWith(
        searchStatus: SearchStatus.error,
        errorMessage: "Email não pode ser vazio",
      ));
      return;
    }

    emit(state.copyWith(searchStatus: SearchStatus.loading));

    try {
      final result = await service.searchUserByEmail(email);

      if (group.memberUserIds.contains(result.id)) {
        emit(state.copyWith(
          searchStatus: SearchStatus.error,
          errorMessage: "Este usuário já é membro do grupo",
        ));
        return;
      }

      final pendingInvite =
          await service.checkPendingInvitation(groupId, email);

      emit(state.copyWith(
        searchStatus: SearchStatus.success,
        foundUser: result,
        hasExistingInvite: pendingInvite != null,
      ));
    } catch (e) {
      emit(state.copyWith(
        searchStatus: SearchStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> sendInvitation(String email) async {
    if (email.trim().isEmpty) {
      emit(state.copyWith(
        inviteStatus: InviteStatus.error,
        errorMessage: "Email não pode ser vazio",
      ));
      return;
    }

    emit(state.copyWith(inviteStatus: InviteStatus.loading));

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != group.adminUserId) {
        emit(state.copyWith(
          inviteStatus: InviteStatus.error,
          errorMessage: "Apenas o administrador pode enviar convites",
        ));
        return;
      }

      await service.createGroupInvitation(
        groupId: groupId,
        groupName: group.name,
        inviteeEmail: email,
      );

      emit(state.copyWith(
        inviteStatus: InviteStatus.success,
        successMessage: "Convite enviado com sucesso",
      ));
    } catch (e) {
      emit(state.copyWith(
        inviteStatus: InviteStatus.error,
        errorMessage: "Erro ao enviar convite: ${e.toString()}",
      ));
    }
  }

  Future<void> loadPendingInvitations() async {
    emit(state.copyWith(invitationsStatus: InvitationsStatus.loading));

    try {
      final invitations = await service.getGroupPendingInvitations(groupId);

      emit(state.copyWith(
        invitationsStatus: InvitationsStatus.loaded,
        pendingInvitations: invitations,
      ));
    } catch (e) {
      emit(state.copyWith(
        invitationsStatus: InvitationsStatus.error,
        errorMessage: "Erro ao carregar convites: ${e.toString()}",
      ));
    }
  }

  Future<void> cancelInvitation(String invitationId) async {
    emit(state.copyWith(inviteStatus: InviteStatus.loading));

    try {
      await service.updateInvitationStatus(invitationId, 'cancelled');

      await loadPendingInvitations();

      emit(state.copyWith(
        inviteStatus: InviteStatus.success,
        successMessage: "Convite cancelado com sucesso",
      ));
    } catch (e) {
      emit(state.copyWith(
        inviteStatus: InviteStatus.error,
        errorMessage: "Erro ao cancelar convite: ${e.toString()}",
      ));
    }
  }

  void resetSearch() {
    emit(state.copyWith(
      searchStatus: SearchStatus.initial,
      foundUser: null,
      hasExistingInvite: false,
    ));
  }

  void resetMessages() {
    emit(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }
}
