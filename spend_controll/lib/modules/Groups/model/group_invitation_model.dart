import 'package:cloud_firestore/cloud_firestore.dart';

class GroupInvitation {
  final String id;
  final String groupId;
  final String groupName;
  final String inviterUserId;
  final String inviteeEmail;
  final String? inviteeUserId;
  final Timestamp createdAt;
  final String status;

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
}
