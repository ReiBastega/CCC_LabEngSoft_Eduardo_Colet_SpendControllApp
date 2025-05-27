import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/service/service.dart';

part 'forgot_password_state.dart';

class ForgotPasswordController extends Cubit<ForgotPasswordState> {
  final Service service;
  final FirebaseAuth auth;

  ForgotPasswordController({
    required this.service,
    required this.auth,
  }) : super(ForgotPasswordState.initial());

  Future<void> sendResetLink(String email) async {
    emit(state.copyWith(status: ForgotPasswordStatus.loading));
    try {
      await auth.sendPasswordResetEmail(email: email);
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
