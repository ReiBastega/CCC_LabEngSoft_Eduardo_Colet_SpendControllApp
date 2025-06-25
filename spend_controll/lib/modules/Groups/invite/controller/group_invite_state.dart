import 'package:spend_controll/modules/Groups/model/group_invitation_model.dart';
import 'package:spend_controll/modules/service/service_extension.dart';

enum SearchStatus { initial, loading, success, error }

enum InviteStatus { initial, loading, success, error }

enum InvitationsStatus { initial, loading, loaded, error }

class GroupInviteState {
  final SearchStatus searchStatus;
  final InviteStatus inviteStatus;
  final InvitationsStatus invitationsStatus;
  final UserModel? foundUser;
  final bool hasExistingInvite;
  final List<GroupInvitation> pendingInvitations;
  final String? errorMessage;
  final String? successMessage;

  const GroupInviteState({
    required this.searchStatus,
    required this.inviteStatus,
    required this.invitationsStatus,
    this.foundUser,
    required this.hasExistingInvite,
    required this.pendingInvitations,
    this.errorMessage,
    this.successMessage,
  });

  const GroupInviteState.initial()
      : searchStatus = SearchStatus.initial,
        inviteStatus = InviteStatus.initial,
        invitationsStatus = InvitationsStatus.initial,
        foundUser = null,
        hasExistingInvite = false,
        pendingInvitations = const [],
        errorMessage = null,
        successMessage = null;

  GroupInviteState copyWith({
    SearchStatus? searchStatus,
    InviteStatus? inviteStatus,
    InvitationsStatus? invitationsStatus,
    UserModel? foundUser,
    bool? hasExistingInvite,
    List<GroupInvitation>? pendingInvitations,
    String? errorMessage,
    String? successMessage,
  }) {
    return GroupInviteState(
      searchStatus: searchStatus ?? this.searchStatus,
      inviteStatus: inviteStatus ?? this.inviteStatus,
      invitationsStatus: invitationsStatus ?? this.invitationsStatus,
      foundUser: foundUser ?? this.foundUser,
      hasExistingInvite: hasExistingInvite ?? this.hasExistingInvite,
      pendingInvitations: pendingInvitations ?? this.pendingInvitations,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
