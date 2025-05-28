import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/auth/login/controller/login_controller.dart';
import 'package:spend_controll/modules/auth/login/login_module.dart';
import 'package:spend_controll/modules/transactions/add_expense/add_expense_module.dart';
import 'package:spend_controll/modules/transactions/add_income/add_income_module.dart';
import 'package:spend_controll/modules/transactions/transfer/transfer_module.dart';

class TransactionModules extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton<LoginController>(
            (i) => LoginController(service: i(), auth: i())),
        Bind.singleton((i) => FirebaseAuth.instance),
        Bind.singleton((i) => FirebaseFirestore.instance),
      ];

  @override
  List<ModularRoute> get routes => [
        ModuleRoute('/', module: LoginModule()),
        ModuleRoute('/add-expense/', module: AddExpenseModule()),
        ModuleRoute('/add-income/', module: AddIncomeModule()),
        ModuleRoute('/transfer/', module: TransferModule()),
      ];
}
