import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/Groups/detail/detail_module.dart';
import 'package:spend_controll/modules/Groups/group/group_module.dart';
import 'package:spend_controll/modules/auth/login/controller/login_controller.dart';

class GroupsModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton<LoginController>(
            (i) => LoginController(service: i(), auth: i())),
        Bind.singleton((i) => FirebaseAuth.instance),
        Bind.singleton((i) => FirebaseFirestore.instance),
      ];

  @override
  List<ModularRoute> get routes => [
        ModuleRoute('/group/', module: GroupModule()),
        ModuleRoute('/detail/', module: DetailModule()),
      ];
}
