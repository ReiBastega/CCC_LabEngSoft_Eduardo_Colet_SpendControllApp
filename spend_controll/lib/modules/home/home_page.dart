import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/auth/controller/login_controller.dart';
import 'package:spend_controll/modules/home/controller/home_controller.dart';
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
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
            ),
            title: 'Log out',
            func: () {
              widget.loginController.logout();
              Modular.to.pushNamed('/');
            },
          ),
          DrawerTile(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: 'Excluir conta',
            func: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Excluir conta'),
                  content: const Text(
                      'Tem certeza? Esta ação não pode ser desfeita.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(_, false),
                        child: const Text('Cancelar')),
                    TextButton(
                        onPressed: () => Navigator.pop(_, true),
                        child: const Text('Excluir')),
                  ],
                ),
              );
              if (confirm == true) {
                await widget.homeController.deleteAccount();
                widget.loginController.logout();
                Modular.to.navigate('/');
              }
            },
          ),
        ],
      ),
      body: const Column(),
    );
  }
}
