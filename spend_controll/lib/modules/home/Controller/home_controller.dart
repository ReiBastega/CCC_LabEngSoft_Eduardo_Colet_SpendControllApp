import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/modules/home/controller/home_state.dart';
import 'package:spend_controll/modules/transactions/model/transaction_model.dart'
    as transaction_model;

class HomeController extends Cubit<HomeState> {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot>? _groupsSub;
  StreamSubscription<QuerySnapshot>? _recentTxSub;
  StreamSubscription<QuerySnapshot>? _allTxSub;
  StreamSubscription<QuerySnapshot>? _monthlySub;

  HomeController({
    required this.auth,
    required this.firestore,
  }) : super(const HomeState.initial()) {
    _authSub = auth.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    _cancelAllSubs();

    if (user == null) {
      emit(state.copyWith(isAuthenticated: false));
      return;
    }

    emit(state.copyWith(
      status: HomeStatus.loading,
      isAuthenticated: true,
    ));

    _fetchUserName(user.uid);

    _listenGroups(user.uid);
    _listenRecentTransactions(user.uid);
    _listenAllTransactions(user.uid);
    _listenMonthlySummary(user.uid);
  }

  void _listenGroups(String uid) {
    _groupsSub = firestore
        .collection('groups')
        .where('memberUserIds', arrayContains: uid)
        .snapshots()
        .listen((snap) {
      final groups = snap.docs.map((doc) {
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
          adminUserName: data['adminUserName']?.toString() ?? '',
        );
      }).toList();

      emit(state.copyWith(
        status: HomeStatus.success,
        groups: groups,
      ));
    }, onError: (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessege: e.toString(),
      ));
    });
  }

  void _listenRecentTransactions(String uid) {
    _recentTxSub = firestore
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .limit(5)
        .snapshots()
        .listen((snap) {
      final recent = snap.docs.map((doc) {
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

      emit(state.copyWith(
        status: HomeStatus.success,
        recentTransactions: recent,
      ));
    });
  }

  Future<void> _fetchUserName(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    final name = doc.data()?['name'] as String? ?? '';
    emit(state.copyWith(userName: name));
  }

  void _listenAllTransactions(String uid) {
    _allTxSub = firestore
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      double wallet = 0.0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0.0).toDouble();
        final type = _getTransactionType(data['type']);
        wallet += (type == transaction_model.TransactionType.income)
            ? amount
            : -amount;
      }
      emit(state.copyWith(
        status: HomeStatus.success,
        totalBalance: wallet,
      ));
    });
  }

  void _listenMonthlySummary(String uid) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    _monthlySub = firestore
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .snapshots()
        .listen((snap) {
      double income = 0, expense = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final amt = (data['amount'] ?? 0.0).toDouble();
        final type = _getTransactionType(data['type']);
        if (type == transaction_model.TransactionType.income) {
          income += amt;
        } else {
          expense += amt;
        }
      }
      emit(state.copyWith(
        status: HomeStatus.success,
        monthlySummary: {
          'income': income,
          'expense': expense,
        },
      ));
    });
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

  void _cancelAllSubs() {
    _groupsSub?.cancel();
    _recentTxSub?.cancel();
    _allTxSub?.cancel();
    _monthlySub?.cancel();
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    _cancelAllSubs();
    return super.close();
  }
}
