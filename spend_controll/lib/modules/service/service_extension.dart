// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:spend_controll/modules/Groups/model/group_invitation_model.dart';
// import 'package:spend_controll/modules/expenses/expense/model/expense_model.dart';
// import 'package:spend_controll/modules/service/service.dart';

// extension ServiceExtension on Service {
//   Future<UserModel> searchUserByEmail(String email) async {
//     try {
//       final result = await FirebaseFirestore.instance
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .limit(1)
//           .get();

//       if (result.docs.isEmpty) {
//         throw Exception("Usuário não encontrado");
//       }

//       final userDoc = result.docs.first;
//       final data = userDoc.data();

//       return UserModel(
//         id: userDoc.id,
//         email: data['email'] ?? '',
//         displayName: data['displayName'],
//         photoUrl: data['photoURL'],
//       );
//     } catch (e) {
//       throw Exception("Erro ao buscar usuário: ${e.toString()}");
//     }
//   }

//   Future<GroupInvitation?> checkPendingInvitation(
//       String groupId, String email) async {
//     try {
//       final result = await FirebaseFirestore.instance
//           .collection('group_invitations')
//           .where('groupId', isEqualTo: groupId)
//           .where('inviteeEmail', isEqualTo: email)
//           .where('status', isEqualTo: 'pending')
//           .limit(1)
//           .get();

//       if (result.docs.isEmpty) {
//         return null;
//       }

//       return GroupInvitation.fromFirestore(result.docs.first);
//     } catch (e) {
//       throw Exception("Erro ao verificar convites: ${e.toString()}");
//     }
//   }

//   Future<void> createGroupInvitation({
//     required String groupId,
//     required String groupName,
//     required String inviteeEmail,
//   }) async {
//     final userId = getCurrentUserId();
//     if (userId == null) {
//       throw Exception("Usuário não autenticado.");
//     }

//     final existingInvite = await checkPendingInvitation(groupId, inviteeEmail);
//     if (existingInvite != null) {
//       throw Exception("Já existe um convite pendente para este email");
//     }

//     // Cria o convite
//     await FirebaseFirestore.instance.collection('group_invitations').add({
//       'groupId': groupId,
//       'groupName': groupName,
//       'inviterUserId': userId,
//       'inviteeEmail': inviteeEmail,
//       'inviteeUserId': null,
//       'createdAt': FieldValue.serverTimestamp(),
//       'status': 'pending',
//     });
//   }

//   Future<List<GroupInvitation>> getGroupPendingInvitations(
//       String groupId) async {
//     final userId = getCurrentUserId();
//     if (userId == null) {
//       throw Exception("Usuário não autenticado.");
//     }

//     final result = await FirebaseFirestore.instance
//         .collection('group_invitations')
//         .where('groupId', isEqualTo: groupId)
//         .where('status', isEqualTo: 'pending')
//         .orderBy('createdAt', descending: true)
//         .get();

//     return result.docs
//         .map((doc) => GroupInvitation.fromFirestore(doc))
//         .toList();
//   }

//   Future<List<GroupInvitation>> getUserPendingInvitations() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       throw Exception("Usuário não autenticado.");
//     }

//     final result = await FirebaseFirestore.instance
//         .collection('group_invitations')
//         .where('inviteeEmail', isEqualTo: user.email)
//         .where('status', isEqualTo: 'pending')
//         .orderBy('createdAt', descending: true)
//         .get();

//     return result.docs
//         .map((doc) => GroupInvitation.fromFirestore(doc))
//         .toList();
//   }

//   Future<void> updateInvitationStatus(
//       String invitationId, String status) async {
//     if (!['accepted', 'declined', 'cancelled'].contains(status)) {
//       throw Exception("Status inválido");
//     }

//     await FirebaseFirestore.instance
//         .collection('group_invitations')
//         .doc(invitationId)
//         .update({
//       'status': status,
//     });

//     if (status == 'accepted') {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         throw Exception("Usuário não autenticado.");
//       }

//       final inviteDoc = await FirebaseFirestore.instance
//           .collection('group_invitations')
//           .doc(invitationId)
//           .get();

//       if (inviteDoc.exists) {
//         final data = inviteDoc.data() as Map<String, dynamic>;
//         final groupId = data['groupId'];

//         await FirebaseFirestore.instance
//             .collection('groups')
//             .doc(groupId)
//             .update({
//           'memberUserIds': FieldValue.arrayUnion([user.uid]),
//         });

//         await FirebaseFirestore.instance
//             .collection('group_invitations')
//             .doc(invitationId)
//             .update({
//           'inviteeUserId': user.uid,
//         });
//       }
//     }
//   }

//   Future<List<Expense>> getGroupExpensesSync(String groupId) async {
//     final userId = getCurrentUserId();
//     if (userId == null) {
//       return [];
//     }

//     if (groupId.isEmpty) {
//       throw Exception("ID do grupo inválido.");
//     }

//     final result = await FirebaseFirestore.instance
//         .collection('groups')
//         .doc(groupId)
//         .collection('expenses')
//         .orderBy('createdAt', descending: true)
//         .get();

//     return result.docs.map((doc) {
//       final data = doc.data();
//       return Expense(
//         id: doc.id,
//         groupId: groupId,
//         description: data['description'] ?? '',
//         amount: (data['amount'] ?? 0).toDouble(),
//         categoryId: data['categoryId'] ?? '',
//         payerUserId: data['payerUserId'] ?? '',
//         participantsUserIds:
//             List<String>.from(data['participantsUserIds'] ?? []),
//         createdAt: data['createdAt'] ?? Timestamp.now(),
//         createdByUserId: data['createdByUserId'] ?? '',
//         receiptImageUrl: data['receiptImageUrl'],
//       );
//     }).toList();
//   }

//   Future<String> addExpenseWithId(Expense expense) async {
//     final userId = getCurrentUserId();
//     if (userId == null) {
//       throw Exception("Usuário não autenticado.");
//     }

//     if (expense.groupId.isEmpty ||
//         expense.description.isEmpty ||
//         expense.amount <= 0 ||
//         expense.payerUserId.isEmpty ||
//         expense.participantsUserIds.isEmpty) {
//       throw Exception("Dados da despesa inválidos.");
//     }

//     final expenseToAdd = Expense(
//       id: '',
//       groupId: expense.groupId,
//       description: expense.description,
//       amount: expense.amount,
//       categoryId: expense.categoryId,
//       payerUserId: expense.payerUserId,
//       participantsUserIds: expense.participantsUserIds,
//       createdAt: Timestamp.now(),
//       createdByUserId: userId,
//       receiptImageUrl: expense.receiptImageUrl,
//     );

//     final docRef = await FirebaseFirestore.instance
//         .collection('groups')
//         .doc(expense.groupId)
//         .collection('expenses')
//         .add(expenseToAdd.toFirestore());

//     return docRef.id;
//   }

//   Future<void> updateExpenseReceiptUrl({
//     required String groupId,
//     required String expenseId,
//     required String receiptUrl,
//   }) async {
//     final userId = getCurrentUserId();
//     if (userId == null) {
//       throw Exception("Usuário não autenticado.");
//     }

//     await FirebaseFirestore.instance
//         .collection('groups')
//         .doc(groupId)
//         .collection('expenses')
//         .doc(expenseId)
//         .update({
//       'receiptImageUrl': receiptUrl,
//     });
//   }
// }

// class UserModel {
//   final String id;
//   final String email;
//   final String? displayName;
//   final String? photoUrl;

//   UserModel({
//     required this.id,
//     required this.email,
//     this.displayName,
//     this.photoUrl,
//   });
// }
