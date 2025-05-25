import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/home/Controller/home_controller.dart';
import 'package:spend_controll/modules/home/home_page.dart';

class HomeModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.lazySingleton<HomeController>((i) => HomeController(service: i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (context, args) => HomePage(
                  homeController: Modular.get(),
                  loginController: Modular.get(),
                ))
      ];
}
