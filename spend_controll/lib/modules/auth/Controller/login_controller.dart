import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/service/service.dart';
part 'login_state.dart';

class LoginController extends Cubit<LoginState> {
  final Service service;
  final FirebaseAuth auth;

  LoginController({
    required this.service,
    required this.auth,
  }) : super(const LoginState.initial());

  Future<void> login(String email, String senha) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      emit(state.copyWith(
        status: LoginStatus.success,
        user: cred.user,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(status: LoginStatus.failure));
      print('Login error: ${e.code} – ${e.message}');
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.failure));
      print('Unexpected error: $e');
    }
  }

  Future<void> logout() async {
    await auth.signOut();
    emit(const LoginState.initial());
  }
}
