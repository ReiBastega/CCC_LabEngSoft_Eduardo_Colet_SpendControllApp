import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String groupId;
  final String description;
  final double amount;
  final String categoryId;
  final String payerUserId;
  final List<String> participantsUserIds;
  final Timestamp createdAt;
  final String createdByUserId;
  final String? receiptImageUrl; // Campo adicionado para URL do comprovante

  Expense({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.payerUserId,
    required this.participantsUserIds,
    required this.createdAt,
    required this.createdByUserId,
    this.receiptImageUrl, // Parâmetro opcional para URL do comprovante
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      categoryId: data['categoryId'] ?? '',
      payerUserId: data['payerUserId'] ?? '',
      participantsUserIds: List<String>.from(data['participantsUserIds'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      createdByUserId: data['createdByUserId'] ?? '',
      receiptImageUrl: data['receiptImageUrl'], // Leitura do campo do Firestore
    );
  }

  // Método para converter um objeto Expense em um Map para o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'description': description,
      'amount': amount,
      'categoryId': categoryId,
      'payerUserId': payerUserId,
      'participantsUserIds': participantsUserIds,
      'createdAt': createdAt,
      'createdByUserId': createdByUserId,
      'receiptImageUrl':
          receiptImageUrl, // Inclusão do campo no Map para o Firestore
    };
  }
}
