import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/Groups/invite/controller/group_invite_controller.dart';
import 'package:spend_controll/modules/Groups/invite/group_invite_page.dart';

class GroupInviteModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.lazySingleton<GroupInviteController>((i) =>
            GroupInviteController(service: i(), groupId: '', group: i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (context, args) => GroupInvitePage(
                  group: args.data['group'],
                )),
      ];
}
