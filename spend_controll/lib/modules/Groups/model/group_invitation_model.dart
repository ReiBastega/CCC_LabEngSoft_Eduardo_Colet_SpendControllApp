import 'package:cloud_firestore/cloud_firestore.dart';

class GroupInvitation {
  final String id;
  final String groupId;
  final String groupName;
  final String inviterUserId;
  final String inviteeEmail;
  final String? inviteeUserId;
  final Timestamp createdAt;
  final String status; // 'pending', 'accepted', 'declined', 'cancelled'
  
  GroupInvitation({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.inviterUserId,
    required this.inviteeEmail,
    this.inviteeUserId,
    required this.createdAt,
    required this.status,
  });
  
  // Construtor a partir de documento do Firestore
  factory GroupInvitation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GroupInvitation(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      groupName: data['groupName'] ?? '',
      inviterUserId: data['inviterUserId'] ?? '',
      inviteeEmail: data['inviteeEmail'] ?? '',
      inviteeUserId: data['inviteeUserId'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'pending',
    );
  }
  
  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'inviterUserId': inviterUserId,
      'inviteeEmail': inviteeEmail,
      'inviteeUserId': inviteeUserId,
      'createdAt': createdAt,
      'status': status,
    };
  }
  
  // Criar uma cópia com alterações
  GroupInvitation copyWith({
    String? id,
    String? groupId,
    String? groupName,
    String? inviterUserId,
    String? inviteeEmail,
    String? inviteeUserId,
    Timestamp? createdAt,
    String? status,
  }) {
    return GroupInvitation(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      inviterUserId: inviterUserId ?? this.inviterUserId,
      inviteeEmail: inviteeEmail ?? this.inviteeEmail,
      inviteeUserId: inviteeUserId ?? this.inviteeUserId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
