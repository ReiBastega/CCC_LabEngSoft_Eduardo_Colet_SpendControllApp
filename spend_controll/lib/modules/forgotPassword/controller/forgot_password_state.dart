part of 'forgot_password_controller.dart';

enum ForgotPasswordStatus { initial, loading, failure, success }

class ForgotPasswordState {
  final ForgotPasswordStatus status;

  const ForgotPasswordState({
    required this.status,
  });

  const ForgotPasswordState.initial()
      : this(status: ForgotPasswordStatus.initial);

  List<Object?> get props => [status];

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
    );
  }
}
