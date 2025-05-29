import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/transactions/transaction_home/controller/transaction_home_controller.dart';
import 'package:spend_controll/modules/transactions/transaction_home/transaction_home_page.dart';

class TransactionHomeModules extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.lazySingleton((i) => TransactionHomeController(service: i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (context, args) =>
                TransactionHomePage(controller: Modular.get()))
      ];
}
