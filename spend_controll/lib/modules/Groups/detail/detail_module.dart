import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/Groups/detail/controller/detail_controller.dart';
import 'package:spend_controll/modules/Groups/detail/detail_page.dart';
import 'package:spend_controll/modules/Groups/group/Controller/group_controller.dart';
import 'package:spend_controll/modules/home/controller/home_controller.dart';
import 'package:spend_controll/modules/service/service.dart';

class DetailModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.lazySingleton((i) => DetailController(
            groupController: i(), firestore: i(), service: i())),
        Bind.lazySingleton(
            (i) => HomeController(service: i(), auth: i(), firestore: i())),
        Bind.lazySingleton((i) => Service()),
        Bind.lazySingleton((i) => GroupController(service: i()))
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/:groupId',
            child: (context, args) => DetailPage(
                  detailController: Modular.get(),
                  groupId: args.params['groupId'],
                  groupController: Modular.get(),
                )),
      ];
}
