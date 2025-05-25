import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/auth/Controller/login_controller.dart';
import 'package:spend_controll/modules/home/Controller/home_controller.dart';
import 'package:spend_controll/shared/widgets/drawer.dart';

class HomePage extends StatefulWidget {
  final HomeController homeController;
  final LoginController loginController;

  const HomePage(
      {super.key, required this.homeController, required this.loginController});

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
        drawer: DrawerWidget(
          drawerTiles: [
            DrawerTile(
              icon: Icon(Icons.logout),
              title: 'Log out',
              func: () {
                widget.loginController.logout();
                Modular.to.pushNamed('/login');
              },
            ),
          ],
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
