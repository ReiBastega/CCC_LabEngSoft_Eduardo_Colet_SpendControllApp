part of 'create_user_controller.dart';

enum CreateUserStatus { initial, loading, success, failure }

class CreateUserState {
  final CreateUserStatus status;
  final String? errorMessage;

  const CreateUserState._({
    required this.status,
    this.errorMessage,
  });

  const CreateUserState.initial() : this._(status: CreateUserStatus.initial);

  List<Object?> get props => [status, errorMessage];

  CreateUserState copyWith({
    CreateUserStatus? status,
    String? errorMessage,
  }) {
    return CreateUserState._(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
