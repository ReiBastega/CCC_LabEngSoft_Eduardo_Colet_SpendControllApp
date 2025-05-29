import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/transactions/transaction_home/controller/transaction_home_state.dart';

class TransactionHomeController extends Cubit<TransactionHomeState> {
  final Service service;

  TransactionHomeController({required this.service})
      : super(const TransactionHomeState.initial());
}
