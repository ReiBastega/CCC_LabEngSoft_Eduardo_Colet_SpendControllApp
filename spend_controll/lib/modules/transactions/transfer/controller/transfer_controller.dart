import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fs;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spend_controll/modules/service/service.dart';
import 'package:spend_controll/modules/transactions/model/group_model.dart';

import 'transfer_state.dart';

class TransferController extends ChangeNotifier {
  TransferState _state = TransferState.initial();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TransferState get state => _state;

  void _updateState(TransferState newState) {
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
          .where('memberUserIds', arrayContains: user.uid)
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

  Future<bool> saveTransfer({
    required String description,
    required double amount,
    required DateTime date,
    required String destinationGroupId,
    required String destinationGroupName,
    String? observation,
    XFile? receiptImage,
  }) async {
    try {
      _updateState(_state.copyWith(isSaving: true, hasError: false));

      final user = _auth.currentUser;
      final userName = await Service().getUserName(user!.uid);

      final transactionRef = _firestore.collection('transactions').doc();

      String? receiptUrl;
      if (receiptImage != null) {
        final storageRef =
            FirebaseStorage.instance.ref('receipts/${transactionRef.id}.jpg');
        final uploadTask = await storageRef.putFile(
          File(receiptImage.path),
          fs.SettableMetadata(contentType: 'image/jpeg'),
        );
        receiptUrl = await uploadTask.ref.getDownloadURL();
      }

      await transactionRef.set({
        'id': transactionRef.id,
        'groupId': destinationGroupId,
        'description': description,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'type': 'transfer',
        'destinationGroupName': destinationGroupName,
        'userId': user.uid,
        'userName': userName,
        'observation': observation,
        'receiptImageUrl': receiptUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('groups').doc(destinationGroupId).update({
        'balance': FieldValue.increment(amount),
        'lastTransaction': Timestamp.fromDate(date),
        'lastTransactionType': 'transfer_in',
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
