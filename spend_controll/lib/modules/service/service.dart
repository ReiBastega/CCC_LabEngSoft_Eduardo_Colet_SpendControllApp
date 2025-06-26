import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spend_controll/modules/Groups/model/group_invitation_model.dart';
import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/modules/expenses/expense/model/expense_model.dart';

class Service {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String? getCurrentUserId() {
    return auth.currentUser?.uid;
  }

  Future<void> logout() async {
    await auth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = auth.currentUser;
    if (user == null) return;

    try {
      await user.delete();

      await firestore.collection('users').doc(user.uid).delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
            "Por favor, faça login novamente para concluir a exclusão da conta.");
      } else {
        throw Exception("Erro ao excluir conta no Auth: ${e.message}");
      }
    } catch (e) {
      throw Exception("Erro ao excluir dados do usuário: $e");
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // --- Group Management ---

  // Cria um novo grupo no Firestore
  Future<void> createGroup(String groupName) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }

    final newGroupRef = firestore.collection('groups').doc();
    final group = Group(
      id: newGroupRef.id,
      name: groupName,
      adminUserId: userId,
      memberUserIds: [userId],
      createdAt: Timestamp.now(),
      balance: 0.0,
      memberCount: 1,
      isPositive: true,
    );

    await newGroupRef.set(group.toFirestore());
  }

  Future<void> addUserToGroup(String groupId, String userEmail) async {
    print(
        "Lógica de adicionar usuário por email pendente de implementação (busca de UID).");
    throw UnimplementedError(
        "Busca de usuário por email não implementada no Service.");
  }

  Future<void> removeUserFromGroup(
      String groupId, String userIdToRemove) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }
    await firestore.collection('groups').doc(groupId).update({
      'memberUserIds': FieldValue.arrayRemove([userIdToRemove]),
    });
  }

  Stream<List<Group>> getUserGroups() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.value([]);
    }

    return firestore
        .collection('groups')
        .where('memberUserIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Group.fromFirestore(doc)).toList();
    });
  }

  Future<void> addExpense(Expense expense) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }
    if (expense.groupId.isEmpty ||
        expense.description.isEmpty ||
        expense.amount <= 0 ||
        expense.payerUserId.isEmpty ||
        expense.participantsUserIds.isEmpty) {
      throw Exception("Dados da despesa inválidos.");
    }

    final expenseToAdd = Expense(
      id: '',
      groupId: expense.groupId,
      description: expense.description,
      amount: expense.amount,
      categoryId: expense.categoryId,
      payerUserId: expense.payerUserId,
      participantsUserIds: expense.participantsUserIds,
      createdAt: Timestamp.now(),
      createdByUserId: userId,
      type: expense.type,
    );

    await firestore
        .collection('groups')
        .doc(expense.groupId)
        .collection('expenses')
        .add(expenseToAdd.toFirestore());
  }

  Future<void> updateExpense(Expense expense) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }
    if (expense.id.isEmpty || expense.groupId.isEmpty) {
      throw Exception("ID da despesa ou do grupo inválido para atualização.");
    }

    await firestore
        .collection('groups')
        .doc(expense.groupId)
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toFirestore());
  }

  Future<void> deleteExpense(String groupId, String expenseId) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }
    if (expenseId.isEmpty || groupId.isEmpty) {
      throw Exception("ID da despesa ou do grupo inválido para exclusão.");
    }
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  Stream<List<Expense>> getGroupExpenses(String groupId) {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.value([]);
    }
    if (groupId.isEmpty) {
      return Stream.error("ID do grupo inválido.");
    }

    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
    });
  }

  // --- Transaction Management ---
  Future<void> addTransaction({
    required String description,
    required double amount,
    required String type,
    required String groupId,
    required String groupName,
  }) async {
    final userId = auth.currentUser!.uid;
    await firestore.collection('transactions').add({
      'userId': userId,
      'description': description,
      'amount': amount,
      'type': type,
      'groupId': groupId,
      'groupName': groupName,
      'date': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel> searchUserByEmail(String email) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        throw Exception("Usuário não encontrado");
      }

      final userDoc = result.docs.first;
      final data = userDoc.data();

      return UserModel(
        id: userDoc.id,
        email: data['email'] ?? '',
        displayName: data['displayName'],
        photoUrl: data['photoURL'],
      );
    } catch (e) {
      throw Exception("Erro ao buscar usuário: ${e.toString()}");
    }
  }

  Future<GroupInvitation?> checkPendingInvitation(
      String groupId, String email) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('group_invitations')
          .where('groupId', isEqualTo: groupId)
          .where('inviteeEmail', isEqualTo: email)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        return null;
      }

      return GroupInvitation.fromFirestore(result.docs.first);
    } catch (e) {
      throw Exception("Erro ao verificar convites: ${e.toString()}");
    }
  }

  Future<void> createGroupInvitation({
    required String groupId,
    required String groupName,
    required String inviteeEmail,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }

    final existingInvite = await checkPendingInvitation(groupId, inviteeEmail);
    if (existingInvite != null) {
      throw Exception("Já existe um convite pendente para este email");
    }

    await FirebaseFirestore.instance.collection('group_invitations').add({
      'groupId': groupId,
      'groupName': groupName,
      'inviterUserId': userId,
      'inviteeEmail': inviteeEmail,
      'inviteeUserId': null,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  Future<List<GroupInvitation>> getGroupPendingInvitations(
      String groupId) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }

    final result = await FirebaseFirestore.instance
        .collection('group_invitations')
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .get();

    return result.docs
        .map((doc) => GroupInvitation.fromFirestore(doc))
        .toList();
  }

  Future<List<GroupInvitation>> getUserPendingInvitations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado.");
    }

    final result = await FirebaseFirestore.instance
        .collection('group_invitations')
        .where('inviteeEmail', isEqualTo: user.email)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .get();

    return result.docs
        .map((doc) => GroupInvitation.fromFirestore(doc))
        .toList();
  }

  Future<void> updateInvitationStatus(
      String invitationId, String status) async {
    if (!['accepted', 'declined', 'cancelled'].contains(status)) {
      throw Exception("Status inválido");
    }

    await FirebaseFirestore.instance
        .collection('group_invitations')
        .doc(invitationId)
        .update({
      'status': status,
    });

    if (status == 'accepted') {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      final inviteDoc = await FirebaseFirestore.instance
          .collection('group_invitations')
          .doc(invitationId)
          .get();

      if (inviteDoc.exists) {
        final data = inviteDoc.data() as Map<String, dynamic>;
        final groupId = data['groupId'];

        await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .update({
          'memberUserIds': FieldValue.arrayUnion([user.uid]),
        });

        await FirebaseFirestore.instance
            .collection('group_invitations')
            .doc(invitationId)
            .update({
          'inviteeUserId': user.uid,
        });
      }
    }
  }

  Future<List<Expense>> getGroupTransactions(String groupId) async {
    final snap = await firestore
        .collection('transactions')
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((d) => Expense.fromFirestore(d)).toList();
  }

  Future<List<Expense>> getGroupExpensesSync(String groupId) async {
    final snap = await firestore
        .collection('transactions')
        .where('groupId', isEqualTo: groupId)
        .where('type', isEqualTo: 'expense')
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((doc) => Expense.fromFirestore(doc)).toList();
  }

  Future<String> addExpenseWithId(Expense expense) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }

    if (expense.groupId.isEmpty ||
        expense.description.isEmpty ||
        expense.amount <= 0 ||
        expense.payerUserId.isEmpty ||
        expense.participantsUserIds.isEmpty) {
      throw Exception("Dados da despesa inválidos.");
    }

    final expenseToAdd = Expense(
      id: '',
      groupId: expense.groupId,
      description: expense.description,
      amount: expense.amount,
      categoryId: expense.categoryId,
      payerUserId: expense.payerUserId,
      participantsUserIds: expense.participantsUserIds,
      createdAt: Timestamp.now(),
      createdByUserId: userId,
      receiptImageUrl: expense.receiptImageUrl,
      type: expense.type,
    );

    final docRef = await FirebaseFirestore.instance
        .collection('groups')
        .doc(expense.groupId)
        .collection('expenses')
        .add(expenseToAdd.toFirestore());

    return docRef.id;
  }

  Future<void> updateExpenseReceiptUrl({
    required String groupId,
    required String expenseId,
    required String receiptUrl,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .doc(expenseId)
        .update({
      'receiptImageUrl': receiptUrl,
    });
  }
}

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}
