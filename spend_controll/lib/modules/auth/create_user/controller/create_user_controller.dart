import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/service/service.dart';

part 'create_user_state.dart';

class CreateUserController extends Cubit<CreateUserState> {
  final FirebaseAuth auth;
  final Service service;
  final FirebaseFirestore firestore;

  CreateUserController({
    required this.auth,
    required this.firestore,
    required this.service,
  }) : super(const CreateUserState.initial());

  Future<void> createUser(
    String name,
    String email,
    String password,
  ) async {
    emit(state.copyWith(status: CreateUserStatus.loading));

    try {
      final userCred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user?.uid;
      if (uid != null) {
        await firestore.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      emit(state.copyWith(status: CreateUserStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: CreateUserStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CreateUserStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
