import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/service/service.dart';
part 'home_state.dart';

class HomeController extends Cubit<HomeState> {
  final Service service;

  HomeController({required this.service}) : super(const HomeState.initial());

  Future<void> updateCurrentPassword(String currentPassword) async {
    emit(state.copyWith());
  }

  Future<void> updateToken() async {}
}
