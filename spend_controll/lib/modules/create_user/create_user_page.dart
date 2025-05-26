import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/create_user/controller/create_user_controller.dart';
import 'package:spend_controll/shared/widgets/button.dart';
import 'package:spend_controll/shared/widgets/form_input_and_title.dart';

class CreateUserPage extends StatefulWidget {
  final CreateUserController createUserController;

  const CreateUserPage({super.key, required this.createUserController});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.createUserController.createUser(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateUserController, CreateUserState>(
      bloc: widget.createUserController,
      listener: (context, state) {
        if (state.status == CreateUserStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário criado com sucesso!')),
          );
          Navigator.of(context).pop();
        } else if (state.status == CreateUserStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: ${state.errorMessage}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Criar Usuário'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormInputAndTitle(
                  controller: _nameController,
                  hintText: 'Nome',
                  maskFormatter: const [],
                  onSaved: (p0) {},
                  title: 'Nome',
                  iconPath: Icons.person,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 24),
                FormInputAndTitle(
                  controller: _emailController,
                  hintText: 'Email',
                  maskFormatter: const [],
                  onSaved: (p0) {},
                  title: 'Email',
                  iconPath: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o email';
                    }
                    final regex = RegExp(r"^[^@]+@[^@]+\.[^@]+$");
                    if (!regex.hasMatch(value)) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FormInputAndTitle(
                  hintText: 'Senha',
                  maskFormatter: const [],
                  onSaved: (p0) {},
                  title: 'Senha',
                  iconPath: Icons.lock,
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6
                      ? 'Senha deve ter ao menos 6 caracteres'
                      : null,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BlocBuilder<CreateUserController, CreateUserState>(
          bloc: widget.createUserController,
          builder: (context, state) {
            if (state.status == CreateUserStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
              child: Button(
                onPressed: _onSubmit,
                text: 'Cadastrar',
              ),
            );
          },
        ),
      ),
    );
  }
}
