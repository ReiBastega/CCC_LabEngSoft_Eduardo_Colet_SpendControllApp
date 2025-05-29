import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/transactions/model/group_model.dart';
import 'package:spend_controll/modules/transactions/model/transaction_model.dart';
import 'package:spend_controll/shared/widgets/transaction_empty_state.dart';
import 'package:spend_controll/shared/widgets/transaction_filter_widget.dart';
import 'package:spend_controll/shared/widgets/transaction_list_item.dart';
import 'package:spend_controll/shared/widgets/transaction_loading_widget.dart';
import 'package:spend_controll/shared/widgets/transaction_summary_card.dart';

import 'controller/transaction_home_controller.dart';

class TransactionHomePage extends StatefulWidget {
  final TransactionHomeController controller;
  const TransactionHomePage({super.key, required this.controller});

  @override
  State<TransactionHomePage> createState() => _TransactionHomePageState();
}

class _TransactionHomePageState extends State<TransactionHomePage> {
  final TransactionHomeController controller =
      Modular.get<TransactionHomeController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.loadTransactions();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !controller.state.isLoadingMore &&
          controller.state.hasMoreTransactions) {
        controller.loadMoreTransactions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: widget.controller,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Transações'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _showSearchDialog();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    _showFilterBottomSheet();
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await widget.controller.refreshTransactions();
              },
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, state) {
                  if (controller.state.isLoading &&
                      controller.state.transactions.isEmpty) {
                    return const TransactionLoadingWidget();
                  }

                  if (controller.state.hasError &&
                      controller.state.transactions.isEmpty) {
                    return _buildErrorState();
                  }

                  if (controller.state.transactions.isEmpty) {
                    return const TransactionEmptyState();
                  }

                  return _buildTransactionsList();
                },
              ),
            ),
            floatingActionButton: _buildFloatingActionButton(),
          );
        });
  }

  Widget _buildTransactionsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TransactionSummaryCard(
            totalIncome: controller.state.totalIncome,
            totalExpense: controller.state.totalExpense,
            period: _getPeriodText(),
          ),
        ),
        if (_hasActiveFilters())
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildActiveFiltersChips(),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: controller.state.transactions.length +
                (controller.state.hasMoreTransactions ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.state.transactions.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final transaction = controller.state.transactions[index];
              final isFirstOfDay = index == 0 ||
                  !_isSameDay(transaction.date,
                      controller.state.transactions[index - 1].date);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFirstOfDay)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Text(
                        _formatDateHeader(transaction.date),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                      ),
                    ),
                  TransactionListItem(
                    transaction: transaction,
                    onTap: () {
                      _showTransactionDetails(transaction);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar transações',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            controller.state.errorMessage ?? 'Ocorreu um erro inesperado',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.loadTransactions,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _showAddTransactionOptions();
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _buildActiveFiltersChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (controller.state.filter.type != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: Text(_getTypeFilterText()),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  controller.clearTypeFilter();
                },
              ),
            ),
          if (controller.state.filter.groupId != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: Text(_getGroupFilterText()),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  controller.clearGroupFilter();
                },
              ),
            ),
          if (controller.state.filter.startDate != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: Text(_getDateFilterText()),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  controller.clearDateFilter();
                },
              ),
            ),
          if (controller.state.filter.searchQuery != null &&
              controller.state.filter.searchQuery!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: Text('"${controller.state.filter.searchQuery}"'),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  controller.clearSearchQuery();
                },
              ),
            ),
          if (_hasActiveFilters())
            TextButton(
              onPressed: () {
                controller.clearAllFilters();
              },
              child: const Text('Limpar Todos'),
            ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return TransactionFilterWidget(
          currentFilter: controller.state.filter,
          groups: controller.state.availableGroups,
          onApplyFilter: (filter) {
            controller.applyFilter(filter);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showSearchDialog() {
    final searchController =
        TextEditingController(text: controller.state.filter.searchQuery);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pesquisar Transações'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Digite o termo de pesquisa',
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.setSearchQuery(searchController.text);
                Navigator.pop(context);
              },
              child: const Text('Pesquisar'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTransactionOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                  title: const Text('Adicionar Despesa'),
                  onTap: () {
                    Navigator.pop(context);
                    Modular.to
                        .pushNamed('/transactions/add-expense')
                        .then((_) => controller.refreshTransactions());
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                  title: const Text('Adicionar Receita'),
                  onTap: () {
                    Navigator.pop(context);
                    Modular.to
                        .pushNamed('/transactions/add-income')
                        .then((_) => controller.refreshTransactions());
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.swap_horiz, color: Colors.white),
                  ),
                  title: const Text('Transferência'),
                  onTap: () {
                    Navigator.pop(context);
                    Modular.to
                        .pushNamed('/transactions/transfer')
                        .then((_) => controller.refreshTransactions());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detalhes da Transação',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              _buildDetailItem('Descrição', transaction.description),
              _buildDetailItem(
                  'Valor', 'R\$ ${transaction.amount.toStringAsFixed(2)}'),
              _buildDetailItem('Data', _formatDate(transaction.date)),
              _buildDetailItem(
                  'Tipo', _getTransactionTypeText(transaction.type)),
              _buildDetailItem('Grupo', transaction.groupName),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Editar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _confirmDeleteTransaction(transaction);
                    },
                    child: const Text('Excluir'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Transação'),
          content: const Text(
              'Tem certeza que deseja excluir esta transação? Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                controller.deleteTransaction(transaction);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  bool _hasActiveFilters() {
    return controller.state.filter.type != null ||
        controller.state.filter.groupId != null ||
        controller.state.filter.startDate != null ||
        (controller.state.filter.searchQuery != null &&
            controller.state.filter.searchQuery!.isNotEmpty);
  }

  String _getTypeFilterText() {
    switch (controller.state.filter.type) {
      case TransactionType.income:
        return 'Receitas';
      case TransactionType.expense:
        return 'Despesas';
      case TransactionType.transfer:
        return 'Transferências';
      default:
        return 'Todos os tipos';
    }
  }

  String _getGroupFilterText() {
    final group = controller.state.availableGroups.firstWhere(
      (g) => g.id == controller.state.filter.groupId,
      orElse: () => Group(id: '', name: 'Desconhecido'),
    );
    return group.name;
  }

  String _getDateFilterText() {
    final startDate = controller.state.filter.startDate;
    final endDate = controller.state.filter.endDate;

    if (startDate != null && endDate != null) {
      if (_isSameDay(startDate, endDate)) {
        return _formatDate(startDate);
      }
      return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    } else if (startDate != null) {
      return 'A partir de ${_formatDate(startDate)}';
    } else if (endDate != null) {
      return 'Até ${_formatDate(endDate)}';
    }

    return 'Período personalizado';
  }

  String _getPeriodText() {
    final filter = controller.state.filter;

    if (filter.startDate == null && filter.endDate == null) {
      return 'Todas as transações';
    }

    if (filter.startDate != null && filter.endDate != null) {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      if (_isSameDay(filter.startDate!, firstDayOfMonth) &&
          _isSameDay(filter.endDate!, lastDayOfMonth)) {
        return 'Mês atual';
      }

      return '${_formatDate(filter.startDate!)} - ${_formatDate(filter.endDate!)}';
    }

    if (filter.startDate != null) {
      return 'A partir de ${_formatDate(filter.startDate!)}';
    }

    return 'Até ${_formatDate(filter.endDate!)}';
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (_isSameDay(date, now)) {
      return 'Hoje';
    } else if (_isSameDay(date, yesterday)) {
      return 'Ontem';
    } else {
      return _formatDate(date);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getTransactionTypeText(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Receita';
      case TransactionType.expense:
        return 'Despesa';
      case TransactionType.transfer:
        return 'Transferência';
    }
  }
}
