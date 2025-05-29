import 'package:flutter/material.dart';

class TransactionEmptyState extends StatelessWidget {
  const TransactionEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 100, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Nenhuma transação encontrada',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Adicione sua primeira transação usando o botão abaixo ou ajuste os filtros para ver transações existentes.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Icon(Icons.remove, color: Colors.white),
                            ),
                            title: const Text('Adicionar Despesa'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                  context, '/transactions/add-expense');
                            },
                          ),
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                            title: const Text('Adicionar Receita'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                  context, '/transactions/add-income');
                            },
                          ),
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child:
                                  Icon(Icons.swap_horiz, color: Colors.white),
                            ),
                            title: const Text('Transferência'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                  context, '/transactions/transfer');
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Transação'),
          ),
        ],
      ),
    );
  }
}
