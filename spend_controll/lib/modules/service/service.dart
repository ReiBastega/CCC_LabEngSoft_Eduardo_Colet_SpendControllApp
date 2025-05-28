import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/modules/expense/model/expense_model.dart';

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
    if (user == null) {
      return;
    }

    try {
      await firestore.collection('users').doc(user.uid).delete();

      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
            "É necessário fazer login novamente para excluir a conta.");
      } else {
        throw Exception("Erro ao excluir conta: ${e.message}");
      }
    } catch (e) {
      throw Exception("Erro ao excluir conta: $e");
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

  // Adiciona um usuário a um grupo (precisa do email para buscar o UID)
  Future<void> addUserToGroup(String groupId, String userEmail) async {
    // TODO: Implementar busca real de usuário por email
    print(
        "Lógica de adicionar usuário por email pendente de implementação (busca de UID).");
    throw UnimplementedError(
        "Busca de usuário por email não implementada no Service.");
    // Exemplo de como seria:
    // QuerySnapshot userQuery = await firestore.collection('users').where('email', isEqualTo: userEmail).limit(1).get();
    // if (userQuery.docs.isEmpty) { throw Exception("Usuário não encontrado com o email fornecido."); }
    // String userIdToAdd = userQuery.docs.first.id;
    // await firestore.collection('groups').doc(groupId).update({
    //   'memberUserIds': FieldValue.arrayUnion([userIdToAdd]),
    // });
  }

  // Remove um usuário de um grupo
  Future<void> removeUserFromGroup(
      String groupId, String userIdToRemove) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }
    // TODO: Adicionar verificação se o usuário atual é admin
    // TODO: Adicionar verificação para não remover o admin
    await firestore.collection('groups').doc(groupId).update({
      'memberUserIds': FieldValue.arrayRemove([userIdToRemove]),
    });
  }

  // Busca os grupos dos quais o usuário atual é membro
  Stream<List<Group>> getUserGroups() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.value([]); // Retorna stream vazia se não logado
    }

    return firestore
        .collection('groups')
        .where('memberUserIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Group.fromFirestore(doc)).toList();
    });
  }

  // --- Expense Management ---

  // Adiciona uma nova despesa a um grupo
  Future<void> addExpense(Expense expense) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }
    // Validação básica (pode ser expandida)
    if (expense.groupId.isEmpty ||
        expense.description.isEmpty ||
        expense.amount <= 0 ||
        expense.payerUserId.isEmpty ||
        expense.participantsUserIds.isEmpty) {
      throw Exception("Dados da despesa inválidos.");
    }

    // Garante que createdByUserId está correto
    final expenseToAdd = Expense(
        id: '', // Firestore gerará o ID
        groupId: expense.groupId,
        description: expense.description,
        amount: expense.amount,
        categoryId: expense.categoryId, // Assumindo que categoryId é gerenciado
        payerUserId: expense.payerUserId,
        participantsUserIds: expense.participantsUserIds,
        createdAt: Timestamp.now(), // Usa o tempo atual
        createdByUserId: userId // Garante que o criador é o usuário logado
        );

    await firestore
        .collection('groups')
        .doc(expense.groupId)
        .collection('expenses')
        .add(expenseToAdd.toFirestore());
    // TODO: Adicionar lógica para atualizar saldos dos usuários se necessário
  }

  // Atualiza uma despesa existente
  Future<void> updateExpense(Expense expense) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }
    // TODO: Adicionar verificação se o usuário pode editar (criador ou admin do grupo)
    if (expense.id.isEmpty || expense.groupId.isEmpty) {
      throw Exception("ID da despesa ou do grupo inválido para atualização.");
    }

    await firestore
        .collection('groups')
        .doc(expense.groupId)
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toFirestore());
    // TODO: Adicionar lógica para recalcular e atualizar saldos dos usuários
  }

  // Deleta uma despesa
  Future<void> deleteExpense(String groupId, String expenseId) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }
    // TODO: Adicionar verificação se o usuário pode deletar (criador ou admin do grupo)
    if (expenseId.isEmpty || groupId.isEmpty) {
      throw Exception("ID da despesa ou do grupo inválido para exclusão.");
    }
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
    // TODO: Adicionar lógica para reverter e atualizar saldos dos usuários
  }

  // Busca as despesas de um grupo específico
  Stream<List<Expense>> getGroupExpenses(String groupId) {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.value([]); // Retorna stream vazia se não logado
    }
    if (groupId.isEmpty) {
      return Stream.error("ID do grupo inválido.");
    }

    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .orderBy('createdAt', descending: true) // Ordena pelas mais recentes
        .snapshots()
        .map((snapshot) {
      // TODO: Adicionar verificação se o usuário é membro do grupo antes de retornar
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
}
