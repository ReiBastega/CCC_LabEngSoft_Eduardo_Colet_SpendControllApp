part of 'register_controller.dart';

enum RegisterStatus { initial, loading, failure, success }

class RegisterState {
  final RegisterStatus status;
  final String? actualPassword;
  final String? token;

  const RegisterState({
    required this.status,
    required this.actualPassword,
    required this.token,
  });

  const RegisterState.initial()
      : this(
          status: RegisterStatus.initial,
          actualPassword: '',
          token: '',
        );

  List<Object?> get props => [status, actualPassword, token];

  RegisterState copyWith({
    RegisterStatus? status,
    String? actualPassword,
    String? token,
  }) {
    return RegisterState(
      status: status ?? this.status,
      actualPassword: actualPassword ?? this.actualPassword,
      token: token ?? this.token,
    );
  }
}
