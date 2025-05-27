part of 'login_controller.dart';

enum LoginStatus { initial, loading, failure, success }

class LoginState {
  final LoginStatus status;
  final User? user;

  const LoginState({
    required this.status,
    this.user,
  });

  const LoginState.initial() : this(status: LoginStatus.initial);

  List<Object?> get props => [status, user];

  LoginState copyWith({
    LoginStatus? status,
    User? user,
  }) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }
}
