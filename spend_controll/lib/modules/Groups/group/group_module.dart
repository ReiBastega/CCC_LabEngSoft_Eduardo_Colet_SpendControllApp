import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/Groups/group/Controller/group_controller.dart';
import 'package:spend_controll/modules/Groups/group/group_page.dart';

class GroupModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.lazySingleton<GroupController>(
            (i) => GroupController(service: i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (context, args) => GroupListPage(
                  groupController: Modular.get(),
                )),
      ];
}
