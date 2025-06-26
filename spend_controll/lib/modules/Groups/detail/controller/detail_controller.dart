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

      final expenses = await service.getGroupExpensesSync(group.id);

      final memberContributions =
          _calculateMemberContributions(memberDetails, expenses);

      emit(state.copyWith(
        contributionStatus: ContributionStatus.loaded,
        memberContributions: memberContributions,
        expenses: expenses,
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
    List<Expense> expenses,
  ) {
    final Map<String, double> totalPaid = {};
    final Map<String, double> totalOwed = {};

    for (final memberId in memberDetails.keys) {
      totalPaid[memberId] = 0;
      totalOwed[memberId] = 0;
    }

    for (final expense in expenses) {
      if (totalPaid.containsKey(expense.payerUserId)) {
        totalPaid[expense.payerUserId] =
            (totalPaid[expense.payerUserId] ?? 0) + expense.amount;
      }

      final participantsCount = expense.participantsUserIds.length;
      if (participantsCount > 0) {
        final amountPerPerson = expense.amount / participantsCount;

        for (final participantId in expense.participantsUserIds) {
          if (totalOwed.containsKey(participantId)) {
            totalOwed[participantId] =
                (totalOwed[participantId] ?? 0) + amountPerPerson;
          }
        }
      }
    }

    final List<MemberContribution> contributions = [];

    for (final memberId in memberDetails.keys) {
      final paid = totalPaid[memberId] ?? 0;
      final owed = totalOwed[memberId] ?? 0;
      final balance = paid - owed;

      contributions.add(MemberContribution(
        userId: memberId,
        userDetails: memberDetails[memberId]!,
        totalPaid: paid,
        totalOwed: owed,
        balance: balance,
      ));
    }

    contributions.sort((a, b) => a.balance.compareTo(b.balance));

    return contributions;
  }

  void filterExpensesByMember(String? memberId) {
    if (memberId == null) {
      emit(state.copyWith(
        selectedMemberId: null,
        filteredExpenses: state.expenses,
      ));
      return;
    }

    final filteredExpenses = state.expenses.where((expense) {
      return expense.payerUserId == memberId ||
          expense.participantsUserIds.contains(memberId);
    }).toList();

    emit(state.copyWith(
      selectedMemberId: memberId,
      filteredExpenses: filteredExpenses,
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
