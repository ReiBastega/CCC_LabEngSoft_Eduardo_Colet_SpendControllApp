import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/Groups/contribuitions/controller/member_contribuition_state.dart';
import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/modules/Groups/model/member_contribuition.dart';
import 'package:spend_controll/modules/expenses/expense/model/expense_model.dart';
import 'package:spend_controll/modules/service/service.dart';
import 'package:spend_controll/modules/service/service_extension.dart';

class MemberContributionController extends Cubit<MemberContributionState> {
  final Service service;
  final String groupId;
  final Group group;

  MemberContributionController({
    required this.service,
    required this.groupId,
    required this.group,
  }) : super(const MemberContributionState.initial());

  // Carrega os membros do grupo com suas contribuições
  Future<void> loadMembersWithContributions() async {
    emit(state.copyWith(status: ContributionStatus.loading));

    try {
      // Carrega os detalhes dos membros
      final memberDetails = await _loadMemberDetails();

      // Carrega as despesas do grupo
      final expenses = await service.getGroupExpensesSync(groupId);

      // Calcula as contribuições de cada membro
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

  // Carrega os detalhes dos membros (nome, email, etc)
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
        // Se houver erro ao carregar um membro específico, continua com os outros
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

  // Calcula as contribuições de cada membro com base nas despesas
  List<MemberContribution> _calculateMemberContributions(
    Map<String, UserDetails> memberDetails,
    List<Expense> expenses,
  ) {
    // Mapa para armazenar os totais de cada membro
    final Map<String, double> totalPaid = {};
    final Map<String, double> totalOwed = {};

    // Inicializa os mapas com zero para todos os membros
    for (final memberId in memberDetails.keys) {
      totalPaid[memberId] = 0;
      totalOwed[memberId] = 0;
    }

    // Calcula quanto cada membro pagou e quanto deve
    for (final expense in expenses) {
      // Quem pagou a despesa
      if (totalPaid.containsKey(expense.payerUserId)) {
        totalPaid[expense.payerUserId] =
            (totalPaid[expense.payerUserId] ?? 0) + expense.amount;
      }

      // Divide a despesa entre os participantes
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

    // Cria a lista de contribuições
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

    // Ordena por saldo (do mais negativo para o mais positivo)
    contributions.sort((a, b) => a.balance.compareTo(b.balance));

    return contributions;
  }

  // Filtra as despesas por membro específico
  void filterExpensesByMember(String? memberId) {
    if (memberId == null) {
      // Se memberId for null, mostra todas as despesas
      emit(state.copyWith(
        selectedMemberId: null,
        filteredExpenses: state.expenses,
      ));
      return;
    }

    // Filtra despesas onde o membro é pagador ou participante
    final filteredExpenses = state.expenses.where((expense) {
      return expense.payerUserId == memberId ||
          expense.participantsUserIds.contains(memberId);
    }).toList();

    emit(state.copyWith(
      selectedMemberId: memberId,
      filteredExpenses: filteredExpenses,
    ));
  }

  // Limpa o filtro de membros
  void clearMemberFilter() {
    filterExpensesByMember(null);
  }
}

// Enum para os diferentes estados
enum ContributionStatus { initial, loading, loaded, error }

// Modelo para detalhes do usuário
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
