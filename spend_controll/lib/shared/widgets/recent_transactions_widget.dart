import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_controll/modules/transaction/controller/transaction_model.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onTransactionTap;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
    required this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Nenhuma transação recente'),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(context, transaction);
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedDate = dateFormat.format(transaction.date);

    IconData iconData;
    Color iconColor;

    switch (transaction.type) {
      case TransactionType.income:
        iconData = Icons.arrow_downward;
        iconColor = Colors.green;
        break;
      case TransactionType.expense:
        iconData = Icons.arrow_upward;
        iconColor = Colors.red;
        break;
      case TransactionType.transfer:
        iconData = Icons.swap_horiz;
        iconColor = Colors.blue;
        break;
    }

    return ListTile(
      onTap: () => onTransactionTap(transaction),
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.2),
        child: Icon(iconData, color: iconColor),
      ),
      title: Text(
        transaction.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${transaction.groupName} • $formattedDate',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        'R\$ ${transaction.amount.abs().toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: transaction.type == TransactionType.income
                  ? Colors.green
                  : transaction.type == TransactionType.expense
                      ? Colors.red
                      : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
