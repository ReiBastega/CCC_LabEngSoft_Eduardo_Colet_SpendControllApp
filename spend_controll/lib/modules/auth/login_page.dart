import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'Controller/login_controller.dart';

class LoginPage extends StatefulWidget {
  final LoginController loginController;
  const LoginPage({super.key, required this.loginController});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Login',
          ),
        ),
      ),
      body: BlocConsumer<LoginController, LoginState>(
          bloc: widget.loginController,
          listener: (context, state) {
            if (state.status == LoginStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Falha no login')));
            } else if (state.status == LoginStatus.success) {
              Modular.to.navigate('/home');
            }
          },
          builder: (context, state) {
            if (state.status == LoginStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: BlocBuilder<LoginController, LoginState>(
                  bloc: widget.loginController,
                  builder: (context, state) {
                    return Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration:
                              const InputDecoration(labelText: 'E-mail'),
                          onChanged: (value) {
                            email = value;
                          },
                        ),
                        TextField(
                          controller: senhaController,
                          decoration: const InputDecoration(labelText: 'Senha'),
                          obscureText: false,
                          onChanged: (value) {
                            password = value;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            widget.loginController.login(email!, password!);
                            // Modular.to.pushNamed('/home');
                          },
                          child: const Text('Cadastro'),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Modular.to.pushNamed('/home');
                          },
                          child: const Text('Esqueci minha senha'),
                        ),
                      ],
                    );
                  }),
            );
          }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ElevatedButton(
          onPressed: () {
            Modular.to.pushNamed('/home');
          },
          child: const Text('Entrar'),
        ),
      ),
    );
  }
}
