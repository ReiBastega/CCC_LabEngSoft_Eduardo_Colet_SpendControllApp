import 'package:flutter/material.dart';
import 'package:spend_controll/modules/transactions/model/transaction_model.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildTypeIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.groupName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _getAmountColor(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(transaction.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color backgroundColor;
    Color iconColor = Colors.white;

    switch (transaction.type) {
      case TransactionType.income:
        icon = Icons.arrow_upward;
        backgroundColor = Colors.green;
        break;
      case TransactionType.expense:
        icon = Icons.arrow_downward;
        backgroundColor = Colors.red;
        break;
      case TransactionType.transfer:
        icon = Icons.swap_horiz;
        backgroundColor = Colors.blue;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Color _getAmountColor() {
    switch (transaction.type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
