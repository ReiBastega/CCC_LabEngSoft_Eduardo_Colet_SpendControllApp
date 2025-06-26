import 'package:flutter/material.dart';
import 'package:spend_controll/modules/report/controller/report_state.dart';

import '../../modules/transactions/model/group_model.dart';

class ReportFilterWidget extends StatefulWidget {
  final ReportFilter currentFilter;
  final List<Group> groups;
  final List<String> categories;
  final Function(ReportFilter) onApplyFilter;

  const ReportFilterWidget({
    super.key,
    required this.currentFilter,
    required this.groups,
    required this.categories,
    required this.onApplyFilter,
  });

  @override
  State<ReportFilterWidget> createState() => _ReportFilterWidgetState();
}

class _ReportFilterWidgetState extends State<ReportFilterWidget> {
  late ReportFilter _filter;
  final List<String> _selectedGroups = [];
  final List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;

    if (widget.currentFilter.groupIds != null) {
      _selectedGroups.addAll(widget.currentFilter.groupIds!);
    }

    if (widget.currentFilter.categories != null) {
      _selectedCategories.addAll(widget.currentFilter.categories!);
    }
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
                'Filtrar Relatório',
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
          Text(
            'Grupos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(
                  'Todos',
                  _selectedGroups.isEmpty,
                  () {
                    setState(() {
                      _selectedGroups.clear();
                    });
                  },
                ),
                ...widget.groups.map((group) {
                  final isSelected = _selectedGroups.contains(group.id);
                  return _buildFilterChip(
                    group.name,
                    isSelected,
                    () {
                      setState(() {
                        if (isSelected) {
                          _selectedGroups.remove(group.id);
                        } else {
                          _selectedGroups.add(group.id);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Categorias',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildFilterChip(
                'Todas',
                _selectedCategories.isEmpty,
                () {
                  setState(() {
                    _selectedCategories.clear();
                  });
                },
              ),
              ...widget.categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return _buildFilterChip(
                  category,
                  isSelected,
                  () {
                    setState(() {
                      if (isSelected) {
                        _selectedCategories.remove(category);
                      } else {
                        _selectedCategories.add(category);
                      }
                    });
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Incluir Transferências',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: _filter.includeTransfers,
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(includeTransfers: value);
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Agrupamento',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildGroupingChip(
                'Diário',
                _filter.groupingType == GroupingType.daily,
                () {
                  setState(() {
                    _filter =
                        _filter.copyWith(groupingType: GroupingType.daily);
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildGroupingChip(
                'Semanal',
                _filter.groupingType == GroupingType.weekly,
                () {
                  setState(() {
                    _filter =
                        _filter.copyWith(groupingType: GroupingType.weekly);
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildGroupingChip(
                'Mensal',
                _filter.groupingType == GroupingType.monthly,
                () {
                  setState(() {
                    _filter =
                        _filter.copyWith(groupingType: GroupingType.monthly);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newFilter = ReportFilter(
                  groupIds: _selectedGroups.isEmpty ? null : _selectedGroups,
                  categories:
                      _selectedCategories.isEmpty ? null : _selectedCategories,
                  includeTransfers: _filter.includeTransfers,
                  groupingType: _filter.groupingType,
                );

                widget.onApplyFilter(newFilter);
              },
              child: const Text('Aplicar Filtros'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildGroupingChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
