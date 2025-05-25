import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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

  Future<void> signIn(
      String email, String password, BuildContext context) async {
    try {
      emit(state.copyWith(status: LoginStatus.loading));

      final loggedIn = await login(email, password).timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception());
      if (loggedIn) {
        Modular.to.navigate("/home");
      }
    } on AuthException catch (e) {
      emit(state.copyWith(status: LoginStatus.failure));
    } catch (_) {
      emit(state.copyWith(status: LoginStatus.failure));
    }
  }

  Future<void> logout() async {
    await auth.signOut();
    emit(const LoginState.initial());
  }

  bool isLogged() {
    try {
      var currentUser = auth.currentUser;

      return currentUser != null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code);
    }
  }

  Future<bool> checkUser() async {
    try {
      var user = auth.currentUser!;
      await user.reload();
      return auth.currentUser != null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code);
    }
  }

  Future<bool> checkActualUser() async {
    bool logged = isLogged();
    if (!logged) {
      return false;
    }
    // Renovação de login
    bool internetConnection = await InternetConnectionChecker().hasConnection;

    if (internetConnection) {
      bool check = await checkUser().timeout(const Duration(seconds: 10));

      if (check) {
        Modular.to.navigate("/home/");

        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
