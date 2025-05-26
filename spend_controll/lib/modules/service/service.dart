import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spend_controll/modules/expense/expense_model.dart';
import 'package:spend_controll/modules/group/model/group_model.dart';

class Service {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtém o ID do usuário logado
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // --- Group Management ---

  // Cria um novo grupo no Firestore
  Future<void> createGroup(String groupName) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }

    final newGroupRef = _firestore.collection('groups').doc();
    final group = Group(
      id: newGroupRef.id,
      name: groupName,
      adminUserId: userId,
      memberUserIds: [userId], // O criador é o primeiro membro e admin
      createdAt: Timestamp.now(), balance: 0.0, // Inicializa o saldo como 0
      memberCount: 1, // Inicializa com 1 membro (o criador)
      isPositive: true, // Inicializa como positivo
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
    // QuerySnapshot userQuery = await _firestore.collection('users').where('email', isEqualTo: userEmail).limit(1).get();
    // if (userQuery.docs.isEmpty) { throw Exception("Usuário não encontrado com o email fornecido."); }
    // String userIdToAdd = userQuery.docs.first.id;
    // await _firestore.collection('groups').doc(groupId).update({
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
    await _firestore.collection('groups').doc(groupId).update({
      'memberUserIds': FieldValue.arrayRemove([userIdToRemove]),
    });
  }

  // Busca os grupos dos quais o usuário atual é membro
  Stream<List<Group>> getUserGroups() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.value([]); // Retorna stream vazia se não logado
    }

    return _firestore
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

    await _firestore
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

    await _firestore
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
    await _firestore
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

    return _firestore
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

  // --- Outros métodos de serviço (Auth, User, etc.) podem ser adicionados aqui ---
}
