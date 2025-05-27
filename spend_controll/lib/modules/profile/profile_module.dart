import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/profile/controller/profile_controller.dart';
import 'package:spend_controll/modules/profile/profile_page.dart';
import 'package:spend_controll/modules/service/service.dart';

class ProfileModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.lazySingleton((i) => ProfileController(
              service: i(),
            )),
        Bind.lazySingleton((i) => Service())
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (context, args) => ProfilePage(
                  profileController: Modular.get(),
                ))
      ];
}
