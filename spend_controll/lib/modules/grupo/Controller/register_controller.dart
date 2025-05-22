import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/service/service.dart';
part 'register_state.dart';

class RegisterController extends Cubit<RegisterState> {
  final Service service;

  RegisterController({required this.service})
      : super(const RegisterState.initial());

  Future<void> updateCurrentPassword(String currentPassword) async {
    emit(state.copyWith());
  }

  Future<void> updateToken() async {}
}
