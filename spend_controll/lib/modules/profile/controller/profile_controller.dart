import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/profile/controller/profile_state.dart';
import 'package:spend_controll/modules/service/service.dart';

class ProfileController extends Cubit<ProfileState> {
  final Service service;
  ProfileController({required this.service})
      : super(const ProfileState.initial());

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userId = service.getCurrentUserId();
      if (userId == null) return null;
      final userData = await service.getUserData(userId);
      return userData;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      await service.logout();
      emit(state.copyWith(status: ProfileStatus.success));
      Modular.to.pushNamedAndRemoveUntil(
        '/',
        (_) => false,
      );
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Erro ao fazer logout: ${e.toString()}',
      ));
    }
  }

  Future<void> deleteAccount() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      await service.deleteAccount();
      emit(state.copyWith(status: ProfileStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Erro ao excluir conta: ${e.toString()}',
      ));
    }
  }
}
