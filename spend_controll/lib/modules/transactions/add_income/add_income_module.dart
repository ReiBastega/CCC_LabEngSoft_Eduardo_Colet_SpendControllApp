import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/transactions/add_income/add_income_page.dart';
import 'package:spend_controll/modules/transactions/add_income/controller/add_income_controller.dart';

class AddIncomeModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.lazySingleton((i) => AddIncomeController()),
      ];

  @override
  List<ModularRoute> get routes =>
      [ChildRoute('/', child: (context, args) => const AddIncomePage())];
}
