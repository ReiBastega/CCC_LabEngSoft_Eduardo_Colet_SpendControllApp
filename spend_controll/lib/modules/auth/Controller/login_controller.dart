import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/auth/exception/auth.exeptions.dart';

import 'package:spend_controll/modules/service/service.dart';
part 'login_state.dart';

class LoginController extends Cubit<LoginState> {
  final Service service;
  final FirebaseAuth auth;

  LoginController({
    required this.service,
    required this.auth,
  }) : super(const LoginState.initial());

  Future<bool> login(String email, String password) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      final userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      emit(state.copyWith(status: LoginStatus.success));
      return userCredential.user?.uid != null;
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(status: LoginStatus.failure));
      throw AuthException(code: e.code);
    }
  }

  Future<void> logout() async {
    await auth.signOut();
    emit(const LoginState.initial());
  }
}
