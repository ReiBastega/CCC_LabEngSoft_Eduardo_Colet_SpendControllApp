import 'package:flutter/widgets.dart';
import 'package:spend_controll/modules/forgotPassword/controller/forgot_password_controller.dart';

class ForgotPasswordPage extends StatefulWidget {
  final ForgotPasswordController forgotPasswordController;
  const ForgotPasswordPage({
    super.key,
    required this.forgotPasswordController,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
