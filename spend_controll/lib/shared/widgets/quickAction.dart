import 'package:flutter/material.dart';

enum QuickAction {
  addExpense,
  addIncome,
  transfer,
}

class QuickActionsWidget extends StatelessWidget {
  final Function(QuickAction) onActionTap;

  const QuickActionsWidget({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildActionItem(
          context,
          Icons.remove_circle_outline,
          'Adicionar Despesa',
          Colors.red,
          () => onActionTap(QuickAction.addExpense),
        ),
        _buildActionItem(
          context,
          Icons.add_circle_outline,
          'Adicionar Receita',
          Colors.green,
          () => onActionTap(QuickAction.addIncome),
        ),
        _buildActionItem(
          context,
          Icons.swap_horiz,
          'Transferência',
          Colors.blue,
          () => onActionTap(QuickAction.transfer),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withOpacity(0.8),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
