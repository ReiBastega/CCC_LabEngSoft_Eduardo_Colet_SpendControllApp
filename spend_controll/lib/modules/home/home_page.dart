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
      body: BlocBuilder<HomeController, HomeState>(
        bloc: widget.homeController,
        builder: (context, state) {
          if (state.status == HomeStatus.loading) {
            return _buildLoadingState();
          }
          if (state.status == HomeStatus.failure) {
            return _buildErrorState();
          }
          if (!state.isAuthenticated) {
            Future.microtask(() => Modular.to.navigate('/'));
            return Container();
          }
          if (state.groups.isEmpty) {
            return _buildEmptyState();
          }
          if (state.status == HomeStatus.success) {
            return _buildLoadedState();
          }

          return RefreshIndicator(
            onRefresh: () => widget.homeController.loadUserData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                  top: 56, bottom: 32, left: 24, right: 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Olá, ${state.userName?.isNotEmpty == true ? state.userName : 'Usuário'}!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                            Modular.to.pushNamed('/groups/detail/${g.id}');
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    BalanceCardWidget(
                      totalBalance: state.totalBalance,
                      onTap: () => Modular.to.pushNamed('/balance-details/'),
                    ),
                    const SizedBox(height: 24)
                  ]),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: const Color.fromARGB(255, 199, 177, 236),
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
              Modular.to.pushNamed('/transactions/transaction_home/');
              break;
            case 3:
              Modular.to.pushNamed('/report/');
              break;
            case 4:
              Modular.to.pushNamed('/profile/');
              break;
          }
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
              Modular.to.pushNamed('/groups/group/');
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
        padding:
            const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 72),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Olá, ${widget.homeController.state.userName?.isNotEmpty == true ? widget.homeController.state.userName : 'Usuário'}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 24),

            BalanceCardWidget(
              totalBalance: widget.homeController.state.totalBalance,
              onTap: () {
                Modular.to.pushNamed('/transactions/transaction_home/');
              },
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seus Grupos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    Modular.to.pushNamed('/groups/group/');
                  },
                  child: const Text('Ver Todos'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GroupListWidget(
              groups: widget.homeController.state.groups,
              onGroupTap: (group) {
                Modular.to.pushNamed('/groups/detail/${group.id}');
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transações Recentes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    Modular.to.pushNamed('/transactions/transaction_home/');
                  },
                  child: const Text('Ver Todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RecentTransactionsWidget(
              transactions: widget.homeController.state.recentTransactions,
              onTransactionTap: (transaction) async {
                await Modular.to.pushNamed('/transactions/transaction_home',
                    arguments: transaction);
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
                Modular.to.pushNamed('/report/');
              },
            ),
            const SizedBox(height: 24),

            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            QuickActionsWidget(
              onActionTap: (action) async {
                switch (action) {
                  case QuickAction.addExpense:
                    Modular.to.pushNamed('/transactions/add-expense/');
                    break;
                  case QuickAction.addIncome:
                    final changed = await Modular.to
                        .pushNamed<bool>('/transactions/add-income');
                    if (changed == true) {
                      await widget.homeController.loadUserData();
                    }
                    break;
                  case QuickAction.transfer:
                    Modular.to.pushNamed('/transactions/transfer/');
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
}
