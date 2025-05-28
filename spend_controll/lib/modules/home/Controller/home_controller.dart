import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/modules/home/controller/home_state.dart';
import 'package:spend_controll/modules/service/service.dart';
import 'package:spend_controll/modules/transactions/model/transaction_model.dart'
    as transaction_model;

class HomeController extends Cubit<HomeState> implements ChangeNotifier {
  final Service service;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  HomeController(
      {required this.service, required this.auth, required this.firestore})
      : super(const HomeState.initial());

  Future<void> deleteAccount() async {
    final user = auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await firestore.collection('users').doc(user.uid).delete();

      await user.delete();

      emit(state.copyWith(
        status: HomeStatus.success,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessege: e.message ?? 'Erro ao excluir conta',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessege: e.toString()));
    }
  }

  Future<void> loadUserData() async {
    try {
      emit(state.copyWith(status: HomeStatus.loading));

      final user = auth.currentUser;
      if (user == null) {
        emit(state.copyWith(
          errorType: HomeErrorType.unknown,
          isAuthenticated: false,
        ));
        return;
      }

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};
      final userName = userData['name'] ?? user.displayName ?? 'Usuário';

      final groupsSnapshot = await firestore
          .collection('groups')
          .where('memberUserIds', arrayContains: user.uid)
          .get();

      final groups = groupsSnapshot.docs.map((doc) {
        final data = doc.data();
        final members = List<String>.from(data['memberUserIds'] ?? <String>[]);

        return Group(
          id: doc.id,
          name: data['name']?.toString() ?? 'Sem nome',
          balance: (data['balance'] ?? 0.0).toDouble(),
          memberCount: members.length,
          isPositive: (data['balance'] ?? 0.0) >= 0,
          adminUserId: data['adminUserId']?.toString() ?? '',
          createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
          memberUserIds: members,
        );
      }).toList();

      final transactionsSnapshot = await firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .limit(5)
          .get();

      final transactions = transactionsSnapshot.docs.map((doc) {
        final data = doc.data();
        return transaction_model.Transaction(
          id: doc.id,
          description: data['description'] ?? 'Sem descrição',
          amount: (data['amount'] ?? 0.0).toDouble(),
          date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
          type: _getTransactionType(data['type']),
          groupId: data['groupId'] ?? '',
          groupName: data['groupName'] ?? 'Grupo',
        );
      }).toList();

      double totalBalance = groups.fold(0.0, (sum, g) => sum + g.balance);

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final monthlySummarySnapshot = await firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      final Map<String, double> monthlySummary = {
        'income': 0.0,
        'expense': 0.0,
      };
      for (final doc in monthlySummarySnapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0.0).toDouble();
        final type = _getTransactionType(data['type']);
        if (type == transaction_model.TransactionType.income) {
          monthlySummary['income'] = (monthlySummary['income']! + amount);
        } else {
          monthlySummary['expense'] = (monthlySummary['expense']! + amount);
        }
      }

      emit(state.copyWith(
        status: HomeStatus.success,
        userName: userName,
        groups: groups,
        recentTransactions: transactions,
        totalBalance: totalBalance,
        monthlySummary: monthlySummary,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessege: e.toString(),
      ));
    }
  }

  transaction_model.TransactionType _getTransactionType(String? type) {
    switch (type) {
      case 'income':
        return transaction_model.TransactionType.income;
      case 'expense':
        return transaction_model.TransactionType.expense;
      case 'transfer':
        return transaction_model.TransactionType.transfer;
      default:
        return transaction_model.TransactionType.expense;
    }
  }

  @override
  void addListener(VoidCallback listener) {
    // TODO: implement addListener
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  // TODO: implement hasListeners
  bool get hasListeners => throw UnimplementedError();

  @override
  void notifyListeners() {
    // TODO: implement notifyListeners
  }

  @override
  void removeListener(VoidCallback listener) {
    // TODO: implement removeListener
  }
}
