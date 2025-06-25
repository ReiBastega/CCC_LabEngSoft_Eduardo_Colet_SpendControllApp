import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/Groups/invite/controller/group_invite_controller.dart';
import 'package:spend_controll/modules/Groups/invite/group_invite_page.dart';
import 'package:spend_controll/modules/service/service.dart';

class GroupInviteModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        // Bind.lazySingleton<GroupInviteController>((i) =>
        //     GroupInviteController(service: i(), groupId: i(), group: i())),
        Bind.lazySingleton((i) => Service()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) {
          final group = args.data['group'];
          return GroupInvitePage(
            controller: GroupInviteController(
              service: Modular.get(),
              groupId: group.id,
              group: group,
            ),
            group: group,
          );
        }),
      ];
}
