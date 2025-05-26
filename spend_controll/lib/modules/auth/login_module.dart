import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/home/controller/home_controller.dart';
import 'package:spend_controll/modules/service/service.dart';

import 'login_page.dart';

class LoginModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.lazySingleton<Service>((i) => Service()),
        Bind.lazySingleton(
            (i) => HomeController(service: i(), auth: i(), firestore: i())),
        Bind.singleton((i) => FirebaseAuth.instance),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (context, args) => LoginPage(
                  loginController: Modular.get(),
                ))
      ];
}
