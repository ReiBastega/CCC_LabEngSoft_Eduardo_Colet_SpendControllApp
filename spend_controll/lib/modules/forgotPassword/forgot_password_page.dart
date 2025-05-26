import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/forgotPassword/controller/forgot_password_controller.dart';
import 'package:spend_controll/shared/widgets/button.dart';
import 'package:spend_controll/shared/widgets/form_input_and_title.dart';

class ForgotPasswordPage extends StatefulWidget {
  final ForgotPasswordController forgotPasswordController;
  const ForgotPasswordPage({
    super.key,
    required this.forgotPasswordController,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.forgotPasswordController
          .sendResetLink(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordController, ForgotPasswordState>(
      bloc: widget.forgotPasswordController,
      listener: (context, state) {
        if (state.status == ForgotPasswordStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Link de recuperação enviado! Verifique seu e-mail.'),
            ),
          );
          Navigator.of(context).pop();
        } else if (state.status == ForgotPasswordStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: ${state.errorMessage}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Recuperar Senha')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Informe seu e-mail para receber o link de recuperação de senha:',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                FormInputAndTitle(
                  title: 'E-mail',
                  hintText: 'Informe seu e-mail',
                  maskFormatter: const [],
                  onSaved: (p0) => {},
                  iconPath: Icons.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o e-mail';
                    }
                    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!regex.hasMatch(value)) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
            BlocBuilder<ForgotPasswordController, ForgotPasswordState>(
          bloc: widget.forgotPasswordController,
          builder: (context, state) {
            if (state.status == ForgotPasswordStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Button(
                onPressed: _submit,
                text: 'Enviar Link',
              ),
            );
          },
        ),
      ),
    );
  }
}
