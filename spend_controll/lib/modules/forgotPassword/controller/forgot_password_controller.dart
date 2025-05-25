import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/service/service.dart';

part 'forgot_password_state.dart';

class ForgotPasswordController extends Cubit<ForgotPasswordState> {
  final Service service;

  ForgotPasswordController({
    required this.service,
  }) : super(const ForgotPasswordState.initial());
}
