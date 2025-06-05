import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/report/controller/report_state.dart';
import 'package:spend_controll/modules/service/service.dart';

class ReportController extends Cubit<ReportState> {
  final Service service;
  ReportController({required this.service})
      : super(const ReportState.initial());
}
