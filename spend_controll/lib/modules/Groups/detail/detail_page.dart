import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/Groups/detail/controller/detail_controller.dart';
import 'package:spend_controll/modules/Groups/detail/controller/detail_state.dart';
import 'package:spend_controll/modules/Groups/group/Controller/group_controller.dart';
import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/modules/Groups/model/member_contribuition.dart';
import 'package:spend_controll/modules/expenses/expense/controller/expense_controller.dart';
import 'package:spend_controll/modules/expenses/expense/model/expense_model.dart';
import 'package:spend_controll/shared/widgets/appBar.dart';
import 'package:spend_controll/shared/widgets/custom_card.dart';

class DetailPage extends StatefulWidget {
  final DetailController detailController;
  final GroupController groupController;
  final ExpenseController expenseController;
  final String? groupId;

  const DetailPage({
    super.key,
    required this.detailController,
    required this.groupId,
    required this.groupController,
    required this.expenseController,
  }) : assert(groupId != null, 'groupId must not be null');

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  @override
  void initState() {
    super.initState();
    widget.detailController.loadGroupDetail(widget.groupId!);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(pageTitle: 'Detalhes do Grupo'),
      body: BlocBuilder<DetailController, DetailState>(
        bloc: widget.detailController,
        builder: (context, detailState) {
          if (detailState.status == DetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (detailState.status == DetailStatus.failure) {
            return Center(child: Text('Erro: ${detailState.errorMessage}'));
          }
          final group = detailState.groups;
          if (group != null &&
              detailState.memberContributions.isEmpty &&
              detailState.contributionStatus != ContributionStatus.loading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.detailController.loadMembersWithContributions(group);
            });
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              _buildGroupHeader(context, group!),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Resumo por Membro'),
                  Tab(text: 'Transações'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMembersTab(context, detailState),
                    _buildTransactionsTab(context, detailState),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: () {
          final group = widget.detailController.state.groups;
          if (group != null) {
            Modular.to
                .pushNamed('/groups/groupInvite/', arguments: {'group': group});
          }
        },
      ),
    );
  }

  Widget _buildGroupHeader(BuildContext context, Group group) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${group.memberCount} membros • Saldo: R\$ ${group.balance.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(BuildContext context, DetailState state) {
    if (state.status == ContributionStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == ContributionStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Erro ao carregar contribuições'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => widget.detailController
                  .loadMembersWithContributions(
                      widget.detailController.state.groups!),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (state.memberContributions.isEmpty) {
      return const Center(
        child: Text('Nenhum membro encontrado neste grupo'),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSummaryCard(context, state),
        const SizedBox(height: 16),
        ...state.memberContributions.map((contribution) =>
            _buildMemberContributionCard(context, contribution, state)),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, DetailState state) {
    double totalPaid = 0;
    double totalOwed = 0;
    for (final contribution in state.memberContributions) {
      totalPaid += contribution.totalPaid;
      totalOwed += contribution.totalOwed;
    }
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo do Grupo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Total Pago', totalPaid),
            const Divider(),
            _buildSummaryRow('Total Devido', totalOwed),
            const Divider(),
            _buildSummaryRow(
              'Saldo',
              totalPaid - totalOwed,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    final valueColor = value >= 0 ? Colors.green : Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: isTotal ? valueColor : null,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberContributionCard(
    BuildContext context,
    MemberContribution contribution,
    DetailState state,
  ) {
    final isSelected = state.selectedMemberId == contribution.userId;
    final balanceColor = contribution.balance >= 0 ? Colors.green : Colors.red;
    return Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () {
            if (isSelected) {
              widget.detailController.clearMemberFilter();
            } else {
              widget.detailController
                  .filterExpensesByMember(contribution.userId);
              _tabController.animateTo(1);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      backgroundImage: contribution.userDetails.photoUrl != null
                          ? NetworkImage(contribution.userDetails.photoUrl!)
                          : null,
                      child: contribution.userDetails.photoUrl == null
                          ? Text(
                              contribution.userDetails.name[0].toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contribution.userDetails.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (contribution.userDetails.email.isNotEmpty)
                            Text(
                              contribution.userDetails.email,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildContributionDetail(
                      'Pagou',
                      contribution.totalPaid,
                      Colors.blue,
                    ),
                    _buildContributionDetail(
                      'Deve',
                      contribution.totalOwed,
                      Colors.orange,
                    ),
                    _buildContributionDetail(
                      'Saldo',
                      contribution.balance,
                      balanceColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildContributionDetail(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'R\$ ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsTab(BuildContext context, DetailState state) {
    final transactions = state.selectedMemberId != null
        ? state.filteredTransactions
        : state.transactions;
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Nenhuma transação encontrada'),
            if (state.selectedMemberId != null) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => widget.detailController.clearMemberFilter(),
                child: const Text('Limpar filtro'),
              ),
            ],
          ],
        ),
      );
    }
    return Column(
      children: [
        if (state.selectedMemberId != null)
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                const Text('Filtrado por membro:'),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getMemberName(state, state.selectedMemberId!),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => widget.detailController.clearMemberFilter(),
                  tooltip: 'Limpar filtro',
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildExpenseItem(context, transaction, state);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseItem(
    BuildContext context,
    Expense expense,
    DetailState state,
  ) {
    final payerName = _getMemberName(state, expense.payerUserId);
    final hasReceipt = expense.receiptImageUrl != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
          child: Text(
            expense.description[0].toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(expense.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pago por: $payerName'),
            Text(
              'Data: ${_formatDate(expense.createdAt)}',
              style: const TextStyle(fontSize: 12),
            ),
            if (expense.type == 'transfer' && expense.receiptImageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    expense.receiptImageUrl!,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasReceipt)
              const Icon(Icons.receipt_long, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            Text(
              'R\$ ${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  String _getMemberName(DetailState state, String userId) {
    for (final contribution in state.memberContributions) {
      if (contribution.userId == userId) {
        return contribution.userDetails.name;
      }
    }
    return 'Usuário Desconhecido';
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
