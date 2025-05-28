import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/service/service.dart';
import 'package:spend_controll/modules/transactions/transfer/controller/transfer_controller.dart';
import 'package:spend_controll/modules/transactions/transfer/transfer_page.dart';

class TransferModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.lazySingleton((i) => TransferController()),
        Bind.lazySingleton((i) => Service())
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (context, args) => TransferPage(
                  controller: Modular.get(),
                ))
      ];
}
