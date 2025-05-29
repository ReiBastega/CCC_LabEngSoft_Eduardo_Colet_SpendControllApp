import 'package:flutter/material.dart';
import 'package:spend_controll/modules/transactions/transaction_home/controller/transaction_home_controller.dart';

class TransactionHomePage extends StatefulWidget {
  final TransactionHomeController controller;
  const TransactionHomePage({super.key, required this.controller});

  @override
  State<TransactionHomePage> createState() => _TransactionHomePageState();
}

class _TransactionHomePageState extends State<TransactionHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
