import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_controll/shared/widgets/daily_trend_chart_widget.dart';
import 'package:spend_controll/shared/widgets/expense_chart_widget.dart';
import 'package:spend_controll/shared/widgets/group_distribution_widget.dart';
import 'package:spend_controll/shared/widgets/income_chart_widget.dart';
import 'package:spend_controll/shared/widgets/monthly_comparison_widget.dart';
import 'package:spend_controll/shared/widgets/report_empty_state.dart';
import 'package:spend_controll/shared/widgets/report_filter_widget.dart';
import 'package:spend_controll/shared/widgets/report_loading_widget.dart';
import 'package:spend_controll/shared/widgets/transaction_summary_widget.dart';

import 'controller/report_controller.dart';

class ReportPage extends StatefulWidget {
  final ReportController controller;
  const ReportPage({super.key, required this.controller});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    widget.controller.loadReportData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildAppBar(innerBoxIsScrolled),
                _buildPeriodSelector(),
                if (!widget.controller.state.isLoading &&
                    !widget.controller.state.hasError)
                  _buildSummaryHeader(),
                _buildTabBar(),
              ];
            },
            body: _buildBody(),
          );
        },
      ),
      floatingActionButton: _buildExportButton(),
    );
  }

  Widget _buildAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      floating: true,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Relatórios Financeiros',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.analytics_outlined,
                  size: 120,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () {
            _showFilterBottomSheet();
          },
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  _showPeriodPicker();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatPeriod(widget.controller.state.period),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Receitas',
                widget.controller.state.totalIncome,
                Colors.green,
                Icons.arrow_upward,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Despesas',
                widget.controller.state.totalExpense,
                Colors.red,
                Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Saldo',
                widget.controller.state.totalIncome -
                    widget.controller.state.totalExpense,
                (widget.controller.state.totalIncome -
                            widget.controller.state.totalExpense) >=
                        0
                    ? Colors.blue
                    : Colors.red,
                (widget.controller.state.totalIncome -
                            widget.controller.state.totalExpense) >=
                        0
                    ? Icons.account_balance_wallet
                    : Icons.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Visão Geral'),
            Tab(text: 'Categorias'),
            Tab(text: 'Tendências'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.controller.state.isLoading) {
      return const ReportLoadingWidget();
    }

    if (widget.controller.state.hasError) {
      return _buildErrorState();
    }

    if (widget.controller.state.transactions.isEmpty) {
      return const ReportEmptyState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildCategoriesTab(),
        _buildTrendsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Distribuição por Grupo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: GroupDistributionWidget(
            groupData: widget.controller.state.totalsByGroup,
          ),
        ),
        const Divider(height: 32),
        const Text(
          'Resumo de Transações',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TransactionSummaryWidget(
          transactions: widget.controller.state.transactions,
        ),
        const Divider(height: 32),
        const Text(
          'Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          'Maior Despesa',
          widget.controller.getLargestExpense(),
          Icons.arrow_circle_down,
          Colors.red,
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          'Maior Receita',
          widget.controller.getLargestIncome(),
          Icons.arrow_circle_up,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          'Categoria Mais Cara',
          widget.controller.getMostExpensiveCategory(),
          Icons.category,
          Colors.orange,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCategoriesTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Despesas por Categoria',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ExpenseChartWidget(
            expenseData: widget.controller.state.expensesByCategory,
          ),
        ),
        const Divider(height: 32),
        const Text(
          'Receitas por Categoria',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: IncomeChartWidget(
            incomeData: widget.controller.state.incomesByCategory,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTrendsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Comparativo Mensal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: MonthlyComparisonWidget(
            monthlyData: widget.controller.state.monthlyComparison,
          ),
        ),
        const Divider(height: 32),
        const Text(
          'Evolução Diária',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: DailyTrendChartWidget(
            dailyTotals: widget.controller.state.dailyTotals,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildInsightCard(
      String title, String content, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            'Erro ao carregar relatório',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            widget.controller.state.errorMessage ??
                'Ocorreu um erro inesperado',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.controller.loadReportData,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return FloatingActionButton.extended(
      onPressed: widget.controller.state.isGeneratingPdf
          ? null
          : () {
              _showExportOptions();
            },
      backgroundColor: Theme.of(context).primaryColor,
      label: widget.controller.state.isGeneratingPdf
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text('Exportar PDF'),
      icon: widget.controller.state.isGeneratingPdf
          ? Container()
          : const Icon(Icons.picture_as_pdf),
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
        return ReportFilterWidget(
          currentFilter: widget.controller.state.filter,
          groups: widget.controller.state.availableGroups,
          categories: widget.controller.state.availableCategories,
          onApplyFilter: (filter) {
            widget.controller.applyFilter(filter);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Período'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const Divider(),
              _buildPeriodOption(
                'Mês Atual',
                () => _selectPredefinedPeriod('current_month'),
              ),
              _buildPeriodOption(
                'Mês Anterior',
                () => _selectPredefinedPeriod('last_month'),
              ),
              _buildPeriodOption(
                'Trimestre Atual',
                () => _selectPredefinedPeriod('current_quarter'),
              ),
              _buildPeriodOption(
                'Ano Atual',
                () => _selectPredefinedPeriod('current_year'),
              ),
              _buildPeriodOption(
                'Personalizado',
                () => _selectCustomPeriod(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodOption(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _selectPredefinedPeriod(String periodType) {
    final now = DateTime.now();
    late DateTimeRange period;

    switch (periodType) {
      case 'current_month':
        final firstDay = DateTime(now.year, now.month, 1);
        final lastDay = DateTime(now.year, now.month + 1, 0);
        period = DateTimeRange(start: firstDay, end: lastDay);
        break;
      case 'last_month':
        final firstDay = DateTime(now.year, now.month - 1, 1);
        final lastDay = DateTime(now.year, now.month, 0);
        period = DateTimeRange(start: firstDay, end: lastDay);
        break;
      case 'current_quarter':
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        final firstDay = DateTime(now.year, (currentQuarter - 1) * 3 + 1, 1);
        final lastDay = DateTime(now.year, currentQuarter * 3 + 1, 0);
        period = DateTimeRange(start: firstDay, end: lastDay);
        break;
      case 'current_year':
        final firstDay = DateTime(now.year, 1, 1);
        final lastDay = DateTime(now.year, 12, 31);
        period = DateTimeRange(start: firstDay, end: lastDay);
        break;
      default:
        return;
    }

    widget.controller.setPeriod(period);
  }

  Future<void> _selectCustomPeriod() async {
    final initialPeriod = widget.controller.state.period;

    final period = await showDateRangePicker(
      context: context,
      initialDateRange: initialPeriod,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (period != null) {
      widget.controller.setPeriod(period);
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exportar Relatório',
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
                    const Text(
                      'Opções de Exportação',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildExportOptionTile(
                      'Incluir Gráficos',
                      widget.controller.exportOptions.includeCharts,
                      (value) {
                        setState(() {
                          widget.controller.setExportOption(
                            includeCharts: value,
                          );
                        });
                      },
                    ),
                    _buildExportOptionTile(
                      'Incluir Tabela Detalhada',
                      widget.controller.exportOptions.includeDetailedTable,
                      (value) {
                        setState(() {
                          widget.controller.setExportOption(
                            includeDetailedTable: value,
                          );
                        });
                      },
                    ),
                    _buildExportOptionTile(
                      'Incluir Insights',
                      widget.controller.exportOptions.includeInsights,
                      (value) {
                        setState(() {
                          widget.controller.setExportOption(
                            includeInsights: value,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _generateAndSharePdf();
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Gerar PDF'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExportOptionTile(
      String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndSharePdf() async {
    final result = await widget.controller.generatePdf();

    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF gerado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.controller.state.pdfPath != null) {
        _showPdfPreview();
      }
    }
  }

  void _showPdfPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Visualização do PDF',
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
              Expanded(
                child: widget.controller.state.pdfPath != null
                    ? Center(
                        child: Image.asset(
                          'assets/images/pdf_preview.png',
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.picture_as_pdf,
                              size: 100,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Text('Erro ao carregar visualização'),
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.controller.viewPdf();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('Visualizar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.controller.sharePdf();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Compartilhar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatPeriod(DateTimeRange period) {
    final startDate = DateFormat('dd/MM/yyyy').format(period.start);
    final endDate = DateFormat('dd/MM/yyyy').format(period.end);

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    if (_isSameDay(period.start, firstDayOfMonth) &&
        _isSameDay(period.end, lastDayOfMonth)) {
      return 'Mês Atual';
    }

    final firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final lastDayOfLastMonth = DateTime(now.year, now.month, 0);

    if (_isSameDay(period.start, firstDayOfLastMonth) &&
        _isSameDay(period.end, lastDayOfLastMonth)) {
      return 'Mês Anterior';
    }

    return '$startDate - $endDate';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
