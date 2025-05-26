import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/group/Controller/group_controller.dart';
import 'package:spend_controll/modules/group/group_page.dart';
// Import other necessary pages like GroupDetailPage, ExpenseFormPage etc. when created
// import 'package:spend_controll/modules/grupo/group_detail_page.dart';

class GroupModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        // Bind GroupController - it depends on Service, which should be provided globally or in AppModule
        Bind.lazySingleton<GroupController>(
            (i) => GroupController(service: i())),
        // Bind ExpenseController - it also depends on Service
        // Bind.lazySingleton<ExpenseController>((i) => ExpenseController(service: i())),
        // Service needs to be bound, likely in AppModule, assuming it's shared
        // Bind.lazySingleton<Service>((i) => Service()), // Example if Service is bound here
      ];

  @override
  List<ModularRoute> get routes => [
        // Route for the list of groups
        ChildRoute('/',
            child: (context, args) => GroupListPage(
                  groupController: Modular.get(), // Inject GroupController
                )),
        // TODO: Add route for Group Detail Page
        // ChildRoute('/detail/:groupId', child: (context, args) => GroupDetailPage(
        //   groupId: args.params['groupId'],
        //   groupController: Modular.get(),
        //   expenseController: Modular.get(),
        // )),
        // TODO: Add route for Expense Form Page (if it's a separate page)
        // ChildRoute('/expense/new', child: (context, args) => ExpenseFormPage(...)),
        // ChildRoute('/expense/edit/:expenseId', child: (context, args) => ExpenseFormPage(...)),
      ];
}
