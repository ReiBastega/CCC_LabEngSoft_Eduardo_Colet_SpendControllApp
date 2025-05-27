import 'package:spend_controll/modules/Groups/model/group_model.dart';

enum GroupStatus { initial, loading, loaded, error, success }

class GroupState {
  final GroupStatus status;
  final List<Group> groups;
  final String? errorMessage;

  const GroupState({
    required this.status,
    this.groups = const [],
    this.errorMessage,
  });

  const GroupState.initial()
      : this(
          status: GroupStatus.initial,
          groups: const [],
          errorMessage: null,
        );

  GroupState copyWith({
    GroupStatus? status,
    List<Group>? groups,
    String? errorMessage,
  }) {
    return GroupState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
