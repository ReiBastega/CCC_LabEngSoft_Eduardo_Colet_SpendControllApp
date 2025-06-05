import 'package:flutter/material.dart';
import 'package:spend_controll/modules/home/controller/home_controller.dart';
import 'package:spend_controll/modules/report/controller/report_controller.dart';

class ReportPage extends StatefulWidget {
  final ReportController profileController;
  final HomeController homeController;
  const ReportPage(
      {super.key,
      required this.profileController,
      required this.homeController});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
