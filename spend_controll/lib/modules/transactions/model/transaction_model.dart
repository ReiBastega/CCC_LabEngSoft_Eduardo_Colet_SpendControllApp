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
  Transaction copyWith({
    String? description,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? groupId,
    String? groupName,
  }) {
    return Transaction(
      id: id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
    );
  }
}
