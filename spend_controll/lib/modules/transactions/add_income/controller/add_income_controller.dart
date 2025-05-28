import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spend_controll/modules/transactions/model/group_model.dart';

import 'add_income_state.dart';

class AddIncomeController extends ChangeNotifier {
  AddIncomeState _state = AddIncomeState.initial();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AddIncomeState get state => _state;

  void _updateState(AddIncomeState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadGroups() async {
    try {
      _updateState(_state.copyWith(isLoading: true, hasError: false));

      final user = _auth.currentUser;
      if (user == null) {
        _updateState(_state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: 'Usuário não autenticado',
        ));
        return;
      }

      final groupsSnapshot = await _firestore
          .collection('groups')
          .where('members', arrayContains: user.uid)
          .get();

      final groups = groupsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Group(
          id: doc.id,
          name: data['name'] ?? 'Sem nome',
        );
      }).toList();

      _updateState(_state.copyWith(
        isLoading: false,
        groups: groups,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> saveIncome({
    required String description,
    required double amount,
    required DateTime date,
    required String groupId,
    required String groupName,
    String? category,
    String? observation,
  }) async {
    try {
      _updateState(_state.copyWith(isSaving: true, hasError: false));

      final user = _auth.currentUser;
      if (user == null) {
        _updateState(_state.copyWith(
          isSaving: false,
          hasError: true,
          errorMessage: 'Usuário não autenticado',
        ));
        return false;
      }

      // Criar transação no Firestore
      final transactionRef = _firestore.collection('transactions').doc();

      await transactionRef.set({
        'id': transactionRef.id,
        'description': description,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'type': 'income',
        'groupId': groupId,
        'groupName': groupName,
        'userId': user.uid,
        'userName': user.displayName ?? 'Usuário',
        'category': category,
        'observation': observation,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Atualizar saldo do grupo (aumentar o valor da receita)
      await _firestore.collection('groups').doc(groupId).update({
        'balance': FieldValue.increment(amount),
        'lastTransaction': Timestamp.fromDate(date),
        'lastTransactionType': 'income',
      });

      _updateState(_state.copyWith(isSaving: false));
      return true;
    } catch (e) {
      _updateState(_state.copyWith(
        isSaving: false,
        hasError: true,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }
}
