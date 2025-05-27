import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/Groups/group/Controller/group_controller.dart';
import 'package:spend_controll/modules/Groups/group/Controller/group_state.dart';
import 'package:spend_controll/shared/widgets/appBar.dart';

class GroupListPage extends StatefulWidget {
  final GroupController groupController;
  const GroupListPage({
    super.key,
    required this.groupController,
  });

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final TextEditingController groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Criar Novo Grupo'),
          content: TextField(
            controller: groupNameController,
            decoration: const InputDecoration(hintText: "Nome do Grupo"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                groupNameController.clear();
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Criar'),
              onPressed: () {
                final groupName = groupNameController.text.trim();
                if (groupName.isNotEmpty) {
                  widget.groupController.createGroup(groupName);
                  groupNameController.clear();
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Nome do grupo não pode ser vazio.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(pageTitle: 'Meus Grupos'),
      body: BlocConsumer<GroupController, GroupState>(
        bloc: widget.groupController,
        listener: (context, state) {
          if (state.status == GroupStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (state.status == GroupStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Operação realizada com sucesso!')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == GroupStatus.loading && state.groups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == GroupStatus.error && state.groups.isEmpty) {
            return Center(
              child: Text(state.errorMessage ??
                  'Erro ao carregar grupos. Tente novamente.'),
            );
          }

          if (state.groups.isEmpty) {
            return const Center(
              child: Text('Você ainda não participa de nenhum grupo. Crie um!'),
            );
          }

          return ListView.builder(
            itemCount: state.groups.length,
            itemBuilder: (context, index) {
              final group = state.groups[index];
              return ListTile(
                title: Text(group.name),
                subtitle: Text(
                    'Admin: ${group.adminUserId == widget.groupController.service.getCurrentUserId() ? "Você" : group.adminUserId}'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Modular.to.pushNamed('/groups/detail/${group.id}');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context),
        tooltip: 'Criar Grupo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
