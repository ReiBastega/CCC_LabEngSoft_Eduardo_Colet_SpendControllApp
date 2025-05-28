import 'package:flutter_modular/flutter_modular.dart';

import 'add_expense_page.dart';
import 'controller/add_expense_controller.dart';

class AddExpenseModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton((i) => AddExpenseController()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const AddExpensePage()),
      ];
}
