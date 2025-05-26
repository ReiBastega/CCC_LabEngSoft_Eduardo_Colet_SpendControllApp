import 'package:flutter/material.dart';

class BalanceCardWidget extends StatelessWidget {
  final double totalBalance;
  final VoidCallback onTap;

  const BalanceCardWidget({
    super.key,
    required this.totalBalance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = totalBalance >= 0;
    final formattedBalance = 'R\$ ${totalBalance.abs().toStringAsFixed(2)}';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo Total',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formattedBalance,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Ver detalhes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                        ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
