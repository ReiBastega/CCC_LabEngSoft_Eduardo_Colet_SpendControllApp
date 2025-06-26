import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/Groups/detail/controller/detail_state.dart';
import 'package:spend_controll/modules/Groups/group/Controller/group_controller.dart';
import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/modules/Groups/model/member_contribuition.dart';
import 'package:spend_controll/modules/expenses/expense/controller/expense_controller.dart';
import 'package:spend_controll/modules/expenses/expense/model/expense_model.dart';
import 'package:spend_controll/modules/service/service.dart';

class DetailController extends Cubit<DetailState> {
  final Service service;
  final GroupController groupController;
  final ExpenseController expenseController;
  final FirebaseFirestore firestore;

  DetailController({
    required this.service,
    required this.groupController,
    required this.expenseController,
    required this.firestore,
  }) : super(const DetailState.initial());

  Future<void> loadGroupDetail(String groupId) async {
    try {
      emit(state.copyWith(status: DetailStatus.loading));

      final doc = await firestore.collection('groups').doc(groupId).get();
      if (!doc.exists) {
        emit(state.copyWith(
          status: DetailStatus.failure,
          errorMessage: 'Grupo não encontrado.',
        ));
        return;
      }

      final data = doc.data()!;
      final members = List<String>.from(data['memberUserIds'] ?? <String>[]);

      final group = Group(
        id: doc.id,
        name: data['name'] as String? ?? 'Sem nome',
        balance: (data['balance'] ?? 0.0).toDouble(),
        memberCount: members.length,
        isPositive: (data['balance'] ?? 0.0) >= 0,
        adminUserId: data['adminUserId'] as String? ?? '',
        createdAt: data['createdAt'] ?? Timestamp.now(),
        memberUserIds: members,
      );

      emit(state.copyWith(
        status: DetailStatus.success,
        groups: group,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMembersWithContributions(Group group) async {
    emit(state.copyWith(contributionStatus: ContributionStatus.loading));

    try {
      final memberDetails = await _loadMemberDetails(group);

      final expenses = await service.getGroupTransactions(group.id);

      final memberContributions =
          _calculateMemberContributions(memberDetails, expenses);

      emit(state.copyWith(
        contributionStatus: ContributionStatus.loaded,
        memberContributions: memberContributions,
        transactions: expenses,
      ));
    } catch (e) {
      emit(state.copyWith(
        contributionStatus: ContributionStatus.error,
        errorMessage: "Erro ao carregar contribuições: ${e.toString()}",
      ));
    }
  }

  Future<Map<String, UserDetails>> _loadMemberDetails(Group group) async {
    final Map<String, UserDetails> memberDetails = {};

    for (final memberId in group.memberUserIds) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          memberDetails[memberId] = UserDetails(
            id: memberId,
            name: data['displayName'] ?? 'Usuário',
            email: data['email'] ?? '',
            photoUrl: data['photoURL'],
          );
        } else {
          memberDetails[memberId] = UserDetails(
            id: memberId,
            name: 'Usuário Desconhecido',
            email: '',
            photoUrl: null,
          );
        }
      } catch (e) {
        memberDetails[memberId] = UserDetails(
          id: memberId,
          name: 'Erro ao carregar usuário',
          email: '',
          photoUrl: null,
        );
      }
    }

    return memberDetails;
  }

  List<MemberContribution> _calculateMemberContributions(
    Map<String, UserDetails> memberDetails,
    List<Expense> transactions,
  ) {
    final owed = {for (var id in memberDetails.keys) id: 0.0};
    final paid = {for (var id in memberDetails.keys) id: 0.0};

    for (final tx in transactions) {
      if (tx.type == 'expense') {
        final participants = tx.participantsUserIds.isNotEmpty
            ? tx.participantsUserIds
            : memberDetails.keys.toList();
        final share = tx.amount / participants.length;

        for (final u in participants) {
          owed[u] = owed[u]! + share;
        }
      } else if (tx.type == 'transfer') {
        paid[tx.payerUserId] = paid[tx.payerUserId]! + tx.amount;
      }
    }

    return memberDetails.keys.map((userId) {
      final tPaid = paid[userId]!;
      final tOwed = owed[userId]!;
      return MemberContribution(
        userId: userId,
        userDetails: memberDetails[userId]!,
        totalPaid: tPaid,
        totalOwed: tOwed,
        balance: tPaid - tOwed,
      );
    }).toList();
  }

  void filterExpensesByMember(String? memberId) {
    if (memberId == null) {
      emit(state.copyWith(
        selectedMemberId: null,
        filteredTransactions: state.transactions,
      ));
      return;
    }

    final filteredTransactions = state.transactions.where((transaction) {
      return transaction.payerUserId == memberId ||
          transaction.participantsUserIds.contains(memberId);
    }).toList();

    emit(state.copyWith(
      selectedMemberId: memberId,
      filteredTransactions: filteredTransactions,
    ));
  }

  void clearMemberFilter() {
    filterExpensesByMember(null);
  }
}

class UserDetails {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  UserDetails({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });
}
