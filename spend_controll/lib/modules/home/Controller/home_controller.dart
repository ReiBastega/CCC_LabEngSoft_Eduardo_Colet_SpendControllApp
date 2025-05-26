import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/service/service.dart';

part 'home_state.dart';

class HomeController extends Cubit<HomeState> {
  final Service service;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  HomeController(
      {required this.service, required this.auth, required this.firestore})
      : super(const HomeState.initial());

  Future<void> deleteAccount() async {
    final user = auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await firestore.collection('users').doc(user.uid).delete();

      await user.delete();

      emit(state.copyWith(
        status: HomeStatus.success,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessege: e.message ?? 'Erro ao excluir conta',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessege: e.toString()));
    }
  }
}
