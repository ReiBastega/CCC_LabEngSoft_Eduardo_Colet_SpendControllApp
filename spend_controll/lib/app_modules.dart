import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/Groups/groups_module.dart';
import 'package:spend_controll/modules/auth/controller/login_controller.dart';
import 'package:spend_controll/modules/auth/login_module.dart';
import 'package:spend_controll/modules/create_user/create_user_module.dart';
import 'package:spend_controll/modules/forgotPassword/forgot_password_module.dart';
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
        ModuleRoute('/groups', module: GroupsModule()),
        ModuleRoute('/create_user', module: CreateUserModule()),
        ModuleRoute('/forgot_password', module: ForgotPasswordModule()),
      ];
}
