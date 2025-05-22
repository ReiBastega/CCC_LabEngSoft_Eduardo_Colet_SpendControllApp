import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/home/Controller/home_controller.dart';

class HomePage extends StatefulWidget {
  final HomeController homeController;
  const HomePage({super.key, required this.homeController});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: const Column(
          children: [],
        ),
        bottomNavigationBar: ElevatedButton(
            onPressed: () {
              Modular.to.pushNamed('/grupo');
            },
            child: const Text('Proxima pagina')));
  }
}
