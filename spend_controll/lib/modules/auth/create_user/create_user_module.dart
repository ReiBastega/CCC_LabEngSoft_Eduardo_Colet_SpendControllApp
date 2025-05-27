import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/auth/create_user/controller/create_user_controller.dart';
import 'package:spend_controll/modules/auth/create_user/create_user_page.dart';

class CreateUserModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.singleton((i) => FirebaseAuth.instance),
        Bind.singleton((i) => FirebaseFirestore.instance),
        Bind.lazySingleton((i) =>
            CreateUserController(service: i(), auth: i(), firestore: i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (context, args) => CreateUserPage(
                  createUserController: Modular.get(),
                ))
      ];
}
