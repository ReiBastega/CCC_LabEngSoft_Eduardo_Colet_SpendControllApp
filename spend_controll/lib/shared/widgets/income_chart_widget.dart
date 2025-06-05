import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IncomeChartWidget extends StatefulWidget {
  final Map<String, double> incomeData;

  const IncomeChartWidget({
    super.key,
    required this.incomeData,
  });

  @override
  State<IncomeChartWidget> createState() => _IncomeChartWidgetState();
}

class _IncomeChartWidgetState extends State<IncomeChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.incomeData.isEmpty) {
      return _buildEmptyState();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _buildPieSections(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma receita no período',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final sections = <PieChartSectionData>[];
    final sortedEntries = widget.incomeData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalIncome =
        widget.incomeData.values.fold(0.0, (sum, value) => sum + value);

    final colors = [
      Colors.green,
      Colors.teal,
      Colors.lightGreen,
      Colors.lime,
      Colors.cyan,
      Colors.blue,
      Colors.lightBlue,
      Colors.blueAccent,
    ];

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final color = colors[i % colors.length];
      final percentage = (entry.value / totalIncome) * 100;
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;

      sections.add(
        PieChartSectionData(
          color: color,
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildLegend() {
    final sortedEntries = widget.incomeData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalIncome =
        widget.incomeData.values.fold(0.0, (sum, value) => sum + value);

    final colors = [
      Colors.green,
      Colors.teal,
      Colors.lightGreen,
      Colors.lime,
      Colors.cyan,
      Colors.blue,
      Colors.lightBlue,
      Colors.blueAccent,
    ];

    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: List.generate(
        sortedEntries.length,
        (index) {
          final entry = sortedEntries[index];
          final color = colors[index % colors.length];
          final percentage = (entry.value / totalIncome) * 100;

          return SizedBox(
            width: 150,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${entry.key} (${percentage.toStringAsFixed(1)}%)',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
