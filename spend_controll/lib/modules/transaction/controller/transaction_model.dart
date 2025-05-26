enum TransactionType { income, expense, transfer }

class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String groupId;
  final String groupName;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.groupId,
    required this.groupName,
  });
}
