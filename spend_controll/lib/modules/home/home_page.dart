import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:spend_controll/modules/auth/login/controller/login_controller.dart';
import 'package:spend_controll/modules/home/controller/home_controller.dart';
import 'package:spend_controll/modules/home/controller/home_state.dart';
import 'package:spend_controll/shared/widgets/balance_card_widget.dart';
import 'package:spend_controll/shared/widgets/financial_summary_widget.dart';
import 'package:spend_controll/shared/widgets/group_list_widget.dart';
import 'package:spend_controll/shared/widgets/quickAction.dart';
import 'package:spend_controll/shared/widgets/recent_transactions_widget.dart';

class HomePage extends StatefulWidget {
  final HomeController homeController;
  final LoginController loginController;
  const HomePage({
    super.key,
    required this.homeController,
    required this.loginController,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    widget.homeController.loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spend controll'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Modular.to.pushNamed('/notifications/');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Modular.to.pushNamed('/profile/');
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeController, HomeState>(
        bloc: widget.homeController,
        builder: (context, state) {
          // Loading
          if (state.status == HomeStatus.loading || state.isLoading) {
            return _buildLoadingState();
          }
          // Error
          if (state.status == HomeStatus.failure || state.hasError) {
            return _buildErrorState();
          }
          // Não autenticado
          if (!state.isAuthenticated) {
            Future.microtask(() => Modular.to.navigate('/'));
            return Container();
          }
          // Sem grupos ainda
          if (state.groups.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => widget.homeController.loadUserData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, ${state.userName?.isNotEmpty == true ? state.userName : 'Usuário'}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),

                    // 2) Em quais grupos ele participa
                    Text(
                      'Você participa de ${state.groups.length} grupo(s):',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: state.groups.map((g) {
                        return ActionChip(
                          label: Text(g.name),
                          onPressed: () {
                            // Navegar para detalhes do grupo
                            Modular.to.pushNamed('/groups/detail/${g.id}');
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    // 3) O resto do seu layout (_buildLoadedState)
                    BalanceCardWidget(
                      totalBalance: state.totalBalance,
                      onTap: () => Modular.to.pushNamed('/balance-details'),
                    ),
                    const SizedBox(height: 24)
                  ]),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Modular.to.pushNamed('/groups/group/');
              break;
            case 2:
              Modular.to.pushNamed('/transactions/');
              break;
            case 3:
              Modular.to.pushNamed('/reports/');
              break;
            case 4:
              Modular.to.pushNamed('/profile/');
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Mostrar menu de opções para adicionar transações
          _showAddTransactionMenu(context);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando seus dados...'),
        ],
      ),
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
            'Ops! Algo deu errado.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(widget.homeController.state.errorMessage ?? 'Erro desconhecido'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.homeController.loadUserData,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.group_add,
            size: 64,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            'Você ainda não participa de nenhum grupo',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Modular.to.pushNamed('/groups/create');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Criar Meu Primeiro Grupo'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState() {
    return RefreshIndicator(
      onRefresh: () async {
        await widget.homeController.loadUserData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de Saudação e Resumo
            Text(
              'Olá, ${widget.homeController.state.userName ?? "Usuário"}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Card de Saldo Total
            BalanceCardWidget(
              totalBalance: widget.homeController.state.totalBalance,
              onTap: () {
                // Navegar para detalhes do saldo
                Modular.to.pushNamed('/balance-details');
              },
            ),
            const SizedBox(height: 24),

            // Seção de Grupos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seus Grupos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Navegar para lista completa de grupos
                    Modular.to.pushNamed('/groups');
                  },
                  child: const Text('Ver Todos'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GroupListWidget(
              groups: widget.homeController.state.groups,
              onGroupTap: (group) {
                // Navegar para detalhes do grupo
                Modular.to.pushNamed('/groups/${group.id}');
              },
            ),
            const SizedBox(height: 24),

            // Seção de Transações Recentes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transações Recentes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Navegar para lista completa de transações
                    Modular.to.pushNamed('/transactions');
                  },
                  child: const Text('Ver Todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RecentTransactionsWidget(
              transactions: widget.homeController.state.recentTransactions,
              onTransactionTap: (transaction) {
                // Navegar para detalhes da transação
                Modular.to.pushNamed('/transactions/${transaction.id}');
              },
            ),
            const SizedBox(height: 24),

            // Seção de Resumo Financeiro
            Text(
              'Resumo Financeiro',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            FinancialSummaryWidget(
              monthlySummary: widget.homeController.state.monthlySummary,
              onTap: () {
                // Navegar para relatórios detalhados
                Modular.to.pushNamed('/reports');
              },
            ),
            const SizedBox(height: 24),

            // Seção de Ações Rápidas
            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            QuickActionsWidget(
              onActionTap: (action) {
                // Navegar para a ação selecionada
                switch (action) {
                  case QuickAction.addExpense:
                    Modular.to.pushNamed('/transactions/add-expense');
                    break;
                  case QuickAction.addIncome:
                    Modular.to.pushNamed('/transactions/add-income');
                    break;
                  case QuickAction.transfer:
                    Modular.to.pushNamed('/transactions/transfer');
                    break;
                  case QuickAction.reports:
                    Modular.to.pushNamed('/reports');
                    break;
                  case QuickAction.settings:
                    Modular.to.pushNamed('/settings');
                    break;
                  case QuickAction.export:
                    Modular.to.pushNamed('/export');
                    break;
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionMenu(BuildContext context) {
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
                    Modular.to.pushNamed('/transactions/add-expense');
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
                    Modular.to.pushNamed('/transactions/add-income');
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
                    Modular.to.pushNamed('/transactions/transfer');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
