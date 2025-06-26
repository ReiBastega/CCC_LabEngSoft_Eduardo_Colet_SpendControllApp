import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/Groups/contribuitions/controller/member_contribuition_state.dart';
import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/modules/Groups/model/member_contribuition.dart';
import 'package:spend_controll/modules/expenses/expense/model/expense_model.dart';
import 'package:spend_controll/modules/service/service.dart';

class MemberContributionController extends Cubit<MemberContributionState> {
  final Service service;
  final String groupId;
  final Group group;

  MemberContributionController({
    required this.service,
    required this.groupId,
    required this.group,
  }) : super(const MemberContributionState.initial());

  Future<void> loadMembersWithContributions() async {
    emit(state.copyWith(status: ContributionStatus.loading));

    try {
      final memberDetails = await _loadMemberDetails();

      final expenses = await service.getGroupExpensesSync(groupId);

      final memberContributions =
          _calculateMemberContributions(memberDetails, expenses);

      emit(state.copyWith(
        status: ContributionStatus.loaded,
        memberContributions: memberContributions,
        expenses: expenses,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ContributionStatus.error,
        errorMessage: "Erro ao carregar contribuições: ${e.toString()}",
      ));
    }
  }

  Future<Map<String, UserDetails>> _loadMemberDetails() async {
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
