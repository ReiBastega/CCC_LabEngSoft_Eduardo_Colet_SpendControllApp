import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/report/controller/report_controller.dart';
import 'package:spend_controll/modules/report/report_page.dart';

class ReportModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.lazySingleton((i) => ReportController()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (context, args) => ReportPage(
                  controller: Modular.get(),
                )),
      ];
}
