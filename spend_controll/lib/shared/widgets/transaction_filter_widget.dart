import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_controll/modules/transactions/model/group_model.dart';
import 'package:spend_controll/modules/transactions/model/transaction_model.dart';

import '../../modules/transactions/transaction_home/controller/transaction_home_state.dart';

class TransactionFilterWidget extends StatefulWidget {
  final TransactionFilter currentFilter;
  final List<Group> groups;
  final Function(TransactionFilter) onApplyFilter;

  const TransactionFilterWidget({
    super.key,
    required this.currentFilter,
    required this.groups,
    required this.onApplyFilter,
  });

  @override
  State<TransactionFilterWidget> createState() =>
      _TransactionFilterWidgetState();
}

class _TransactionFilterWidgetState extends State<TransactionFilterWidget> {
  late TransactionFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtrar Transações',
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
          const SizedBox(height: 16),

          // Type filter
          Text(
            'Tipo de Transação',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTypeFilterChip(null, 'Todas'),
                const SizedBox(width: 8),
                _buildTypeFilterChip(TransactionType.income, 'Receitas'),
                const SizedBox(width: 8),
                _buildTypeFilterChip(TransactionType.expense, 'Despesas'),
                const SizedBox(width: 8),
                _buildTypeFilterChip(
                    TransactionType.transfer, 'Transferências'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Grupo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            value: _filter.groupId,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Todos os grupos'),
              ),
              ...widget.groups.map((group) {
                return DropdownMenuItem<String>(
                  value: group.id,
                  child: Text(group.name),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _filter = _filter.copyWith(groupId: value);
              });
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Período',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDateFilterChip('today', 'Hoje'),
                const SizedBox(width: 8),
                _buildDateFilterChip('week', 'Esta Semana'),
                const SizedBox(width: 8),
                _buildDateFilterChip('month', 'Este Mês'),
                const SizedBox(width: 8),
                _buildDateFilterChip('custom', 'Personalizado'),
              ],
            ),
          ),

          if (_isCustomDateRange())
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          labelText: 'Data Inicial',
                        ),
                        child: Text(
                          _filter.startDate != null
                              ? DateFormat('dd/MM/yyyy')
                                  .format(_filter.startDate!)
                              : 'Selecionar',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          labelText: 'Data Final',
                        ),
                        child: Text(
                          _filter.endDate != null
                              ? DateFormat('dd/MM/yyyy')
                                  .format(_filter.endDate!)
                              : 'Selecionar',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                widget.onApplyFilter(_filter);
              },
              child: const Text('Aplicar Filtros'),
            ),
          ),

          if (_hasActiveFilters())
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _filter = const TransactionFilter();
                    });
                  },
                  child: const Text('Limpar Filtros'),
                ),
              ),
            ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildTypeFilterChip(TransactionType? type, String label) {
    final isSelected = _filter.type == type;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filter = _filter.copyWith(type: type);
          });
        }
      },
    );
  }

  Widget _buildDateFilterChip(String period, String label) {
    bool isSelected = false;

    if (period == 'custom') {
      isSelected = _isCustomDateRange();
    } else {
      final now = DateTime.now();

      switch (period) {
        case 'today':
          final today = DateTime(now.year, now.month, now.day);
          isSelected = _filter.startDate != null &&
              _filter.endDate != null &&
              _isSameDay(_filter.startDate!, today) &&
              _isSameDay(_filter.endDate!, today);
          break;
        case 'week':
          final firstDayOfWeek = _firstDayOfWeek(now);
          final lastDayOfWeek = _lastDayOfWeek(now);
          isSelected = _filter.startDate != null &&
              _filter.endDate != null &&
              _isSameDay(_filter.startDate!, firstDayOfWeek) &&
              _isSameDay(_filter.endDate!, lastDayOfWeek);
          break;
        case 'month':
          final firstDayOfMonth = DateTime(now.year, now.month, 1);
          final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
          isSelected = _filter.startDate != null &&
              _filter.endDate != null &&
              _isSameDay(_filter.startDate!, firstDayOfMonth) &&
              _isSameDay(_filter.endDate!, lastDayOfMonth);
          break;
      }
    }

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            final now = DateTime.now();

            switch (period) {
              case 'today':
                final today = DateTime(now.year, now.month, now.day);
                _filter = _filter.copyWith(startDate: today, endDate: today);
                break;
              case 'week':
                _filter = _filter.copyWith(
                  startDate: _firstDayOfWeek(now),
                  endDate: _lastDayOfWeek(now),
                );
                break;
              case 'month':
                _filter = _filter.copyWith(
                  startDate: DateTime(now.year, now.month, 1),
                  endDate: DateTime(now.year, now.month + 1, 0),
                );
                break;
              case 'custom':
                // Keep current dates or set defaults
                _filter = _filter.copyWith(
                  startDate:
                      _filter.startDate ?? DateTime(now.year, now.month, 1),
                  endDate: _filter.endDate ?? now,
                );
                break;
            }
          });
        }
      },
    );
  }

  bool _isCustomDateRange() {
    if (_filter.startDate == null || _filter.endDate == null) {
      return false;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfWeek = _firstDayOfWeek(now);
    final lastDayOfWeek = _lastDayOfWeek(now);
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    if (_isSameDay(_filter.startDate!, today) &&
        _isSameDay(_filter.endDate!, today)) {
      return false;
    }

    if (_isSameDay(_filter.startDate!, firstDayOfWeek) &&
        _isSameDay(_filter.endDate!, lastDayOfWeek)) {
      return false;
    }

    if (_isSameDay(_filter.startDate!, firstDayOfMonth) &&
        _isSameDay(_filter.endDate!, lastDayOfMonth)) {
      return false;
    }

    return true;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final initialDate = _filter.startDate ?? DateTime.now();
    final firstDate = DateTime(2020);
    final lastDate = _filter.endDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _filter = _filter.copyWith(startDate: picked);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final initialDate = _filter.endDate ?? DateTime.now();
    final firstDate = _filter.startDate ?? DateTime(2020);
    final lastDate = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _filter = _filter.copyWith(endDate: picked);
      });
    }
  }

  bool _hasActiveFilters() {
    return _filter.type != null ||
        _filter.groupId != null ||
        _filter.startDate != null ||
        _filter.endDate != null;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  DateTime _firstDayOfWeek(DateTime date) {
    final difference = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - difference);
  }

  DateTime _lastDayOfWeek(DateTime date) {
    final difference = 7 - date.weekday;
    return DateTime(date.year, date.month, date.day + difference);
  }
}
