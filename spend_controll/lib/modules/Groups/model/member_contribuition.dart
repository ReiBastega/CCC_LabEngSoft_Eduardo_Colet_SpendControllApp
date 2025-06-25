// Modelo para contribuição de membro
import 'package:spend_controll/modules/Groups/contribuitions/controller/member_contribution_controller.dart';

class MemberContribution {
  final String userId;
  final UserDetails userDetails;
  final double totalPaid;
  final double totalOwed;
  final double balance;

  MemberContribution({
    required this.userId,
    required this.userDetails,
    required this.totalPaid,
    required this.totalOwed,
    required this.balance,
  });
}
