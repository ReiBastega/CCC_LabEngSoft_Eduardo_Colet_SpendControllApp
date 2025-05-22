import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/grupo/Controller/register_controller.dart';
import 'package:spend_controll/modules/grupo/register_page.dart';

class RegisterModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.lazySingleton<RegisterController>(
            (i) => RegisterController(service: i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (context, args) => RegisterPage(
                  registerController: Modular.get(),
                ))
      ];
}
