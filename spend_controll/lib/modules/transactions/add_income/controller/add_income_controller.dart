import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Future<bool> saveIncome({
    required String description,
    required double amount,
    required DateTime date,
    String? category,
    String? observation,
  }) async {
    try {
      _updateState(_state.copyWith(isSaving: true, hasError: false));

      final user = _auth.currentUser;
      if (user == null) throw Exception('Não autenticado');

      final txRef = _firestore.collection('transactions').doc();
      await txRef.set({
        'id': txRef.id,
        'description': description,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'type': 'income',
        'userId': user.uid,
        'userName': user.displayName ?? 'Usuário',
        'category': category,
        'observation': observation,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // **não** atualiza mais nenhum documento de grupo aqui

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
