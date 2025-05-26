import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/shared/widgets/appBar.dart';
import 'package:spend_controll/shared/widgets/button.dart';
import 'package:spend_controll/shared/widgets/form_input_and_title.dart';

import 'controller/login_controller.dart';

class LoginPage extends StatefulWidget {
  final LoginController loginController;
  const LoginPage({super.key, required this.loginController});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final List<FocusNode> _focusNodes = List<FocusNode>.generate(
    2,
    (_) => FocusNode(),
    growable: false,
  );
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  String? email;
  String? password;

  @override
  void initState() {
    widget.loginController.checkActualUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        pageTitle: 'Login',
        showReturn: false,
      ),
      body: BlocConsumer<LoginController, LoginState>(
          bloc: widget.loginController,
          listener: (context, state) {
            if (state.status == LoginStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Falha no login')));
            }
          },
          builder: (context, state) {
            if (state.status == LoginStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FormInputAndTitle(
                    focus: _focusNodes[0],
                    title: 'E-mail',
                    hintText: 'Informe',
                    controller: emailController,
                    maskFormatter: const [],
                    onSaved: (p0) {},
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return 'Campo vazio';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      email = value;
                    },
                  ),
                  FormInputAndTitle(
                    focus: _focusNodes[1],
                    title: 'Senha',
                    hintText: 'Informe',
                    controller: senhaController,
                    maskFormatter: const [],
                    onSaved: (p0) {},
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return 'Campo vazio';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      password = value;
                    },
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      child: const Text('Esqueci minha senha',
                          style: TextStyle(
                            color: Color(0xFF4F4F4F),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          )),
                      onPressed: () {
                        Modular.to.pushNamed('/forgot_password/');
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Button(
                    onPressed: () {
                      widget.loginController.signIn(email!, password!, context);
                    },
                    text: 'Entrar',
                  ),
                ],
              ),
            );
          }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: BlocBuilder<LoginController, LoginState>(
            bloc: widget.loginController,
            builder: (context, state) {
              return TextButton(
                onPressed: () {
                  Modular.to.pushNamed('/create_user/');
                },
                child: const Text('Cadastro',
                    style: TextStyle(
                      color: Color(0xFF4F4F4F),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    )),
              );
            }),
      ),
    );
  }
}
