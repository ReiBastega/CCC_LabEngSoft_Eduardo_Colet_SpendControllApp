import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String adminUserId;
  final List<String> memberUserIds;
  final Timestamp createdAt;
  final double balance;
  final int memberCount;
  final bool isPositive;

  Group({
    required this.id,
    required this.name,
    required this.adminUserId,
    required this.memberUserIds,
    required this.createdAt,
    required this.balance,
    required this.memberCount,
    required this.isPositive,
  });

  // Método para converter um DocumentSnapshot do Firestore em um objeto Group
  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Group(
      id: doc.id,
      name: data['name'] ?? '',
      adminUserId: data['adminUserId'] ?? '',
      // Garante que memberUserIds seja sempre uma lista de strings
      memberUserIds: List<String>.from(data['memberUserIds'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      memberCount: (data['memberUserIds'] as List?)?.length ?? 0,
      isPositive: (data['balance'] ?? 0.0) >= 0,
      balance: (data['balance'] ?? 0.0).toDouble(),
    );
  }

  // Método para converter um objeto Group em um Map para o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'adminUserId': adminUserId,
      'memberUserIds': memberUserIds,
      'createdAt': createdAt,
    };
  }
}
