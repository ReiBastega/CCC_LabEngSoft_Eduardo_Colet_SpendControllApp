part of 'forgot_password_controller.dart';

enum ForgotPasswordStatus { initial, loading, failure, success }

class ForgotPasswordState {
  final ForgotPasswordStatus status;
  final String? errorMessage;

  const ForgotPasswordState({
    required this.status,
    this.errorMessage,
  });

  factory ForgotPasswordState.initial() =>
      const ForgotPasswordState(status: ForgotPasswordStatus.initial);

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
