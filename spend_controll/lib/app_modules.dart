import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/auth/Controller/login_controller.dart';
import 'package:spend_controll/modules/auth/login_module.dart';
import 'package:spend_controll/modules/grupo/register_module.dart';
import 'package:spend_controll/modules/home/home_module.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton<LoginController>(
            (i) => LoginController(service: i(), auth: i())),
        Bind.singleton((i) => FirebaseAuth.instance),
        Bind.singleton((i) => FirebaseFirestore.instance),
      ];

  @override
  List<ModularRoute> get routes => [
        ModuleRoute('/', module: LoginModule()),
        ModuleRoute('/home', module: HomeModule()),
        ModuleRoute('/grupo', module: RegisterModule()),
      ];
}
