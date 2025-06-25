import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/Groups/detail/controller/detail_controller.dart';
import 'package:spend_controll/modules/Groups/detail/controller/detail_state.dart';
import 'package:spend_controll/modules/Groups/group/Controller/group_controller.dart';
import 'package:spend_controll/modules/expenses/expense/controller/expense_controller.dart';

class DetailPage extends StatefulWidget {
  final DetailController detailController;
  final GroupController groupController;
  final ExpenseController expenseController;
  final String? groupId;

  const DetailPage(
      {super.key,
      required this.detailController,
      required this.groupId,
      required this.groupController,
      required this.expenseController})
      : assert(groupId != null, 'groupId must not be null');

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
    widget.detailController.loadGroupDetail(widget.groupId!);
    // widget.expenseController.loadExpensesForGroup(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Grupo'),
        ),
        body: Column(
          children: [
            BlocBuilder<DetailController, DetailState>(
              bloc: widget.detailController,
              builder: (context, state) {
                if (state.status == DetailStatus.loading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state.status == DetailStatus.failure) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Erro: ${state.errorMessage}'),
                  );
                }
                final group = state.groups!;
                return ListTile(
                  title: Text(group.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  subtitle:
                      Text('Saldo: R\$ ${group.balance.toStringAsFixed(2)}'),
                );
              },
            ),
            const Divider(),
            Expanded(
              child: BlocBuilder<ExpenseController, ExpenseState>(
                bloc: widget.expenseController,
                builder: (context, state) {
                  if (state.status == ExpenseStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == ExpenseStatus.error) {
                    return Center(child: Text('Erro: ${state.errorMessage}'));
                  }
                  if (state.expenses.isEmpty) {
                    return const Center(
                        child: Text('Sem despesas neste grupo.'));
                  }
                  return ListView.separated(
                    itemCount: state.expenses.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final e = state.expenses[i];
                      return ListTile(
                        title: Text(e.description),
                        trailing: Text(
                          'R\$ ${e.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: e.amount < 0 ? Colors.red : Colors.green,
                          ),
                        ),
                        // subtitle: Text(
                        //   // ex: formate a data como desejar
                        //   e.date.toLocal().toString().split(' ')[0],
                        // ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.person_add),
            onPressed: () {
              final group = widget.detailController.state.groups;
              if (group != null) {
                Modular.to.pushNamed('/groups/groupInvite/',
                    arguments: {'group': group});
              }
            }));
  }
}
