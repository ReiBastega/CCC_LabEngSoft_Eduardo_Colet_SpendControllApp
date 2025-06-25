import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/Groups/detail/controller/detail_state.dart';
import 'package:spend_controll/modules/Groups/group/Controller/group_controller.dart';
import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/modules/expenses/expense/controller/expense_controller.dart';
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

  /// Busca os detalhes do grupo [groupId] no Firestore
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
}
