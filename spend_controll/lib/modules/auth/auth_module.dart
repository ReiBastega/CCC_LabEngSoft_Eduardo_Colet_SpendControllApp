import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/auth/create_user/create_user_module.dart';
import 'package:spend_controll/modules/auth/forgotPassword/forgot_password_module.dart';
import 'package:spend_controll/modules/auth/login/controller/login_controller.dart';
import 'package:spend_controll/modules/auth/login/login_module.dart';

class AuthModule extends Module {
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
        ModuleRoute('/create_user', module: CreateUserModule()),
        ModuleRoute('/forgot_password', module: ForgotPasswordModule()),
      ];
}
