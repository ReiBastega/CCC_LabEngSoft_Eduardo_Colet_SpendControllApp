import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/auth/forgotPassword/controller/forgot_password_controller.dart';
import 'package:spend_controll/modules/auth/forgotPassword/forgot_password_page.dart';

class ForgotPasswordModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.lazySingleton(
            (i) => ForgotPasswordController(service: i(), auth: i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (context, args) => ForgotPasswordPage(
                  forgotPasswordController: Modular.get(),
                ))
      ];
}
