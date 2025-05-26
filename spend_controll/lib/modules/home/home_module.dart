import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/home/controller/home_controller.dart';
import 'package:spend_controll/modules/home/home_page.dart';
import 'package:spend_controll/modules/service/service.dart';

class HomeModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.lazySingleton(
            (i) => HomeController(service: i(), auth: i(), firestore: i())),
        Bind.lazySingleton((i) => Service())
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
