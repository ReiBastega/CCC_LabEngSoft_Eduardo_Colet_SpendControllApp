import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GroupDistributionWidget extends StatelessWidget {
  final Map<String, double> groupData;

  const GroupDistributionWidget({
    super.key,
    required this.groupData,
  });

  @override
  Widget build(BuildContext context) {
    if (groupData.isEmpty) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue() * 1.2,
                  minY: _getMinValue() * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) =>
                          Colors.blueGrey.withOpacity(0.8),
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final entry = groupData.entries.elementAt(groupIndex);
                        return BarTooltipItem(
                          '${entry.key}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'R\$ ${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value >= 0 && value < groupData.length) {
                            final name =
                                groupData.keys.elementAt(value.toInt());
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _abbreviateGroupName(name),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'R\$ ${value.toInt()}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: _buildBarGroups(),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: _getMaxValue() / 5,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
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
              Icons.bar_chart,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum dado de grupo disponível',
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

  List<BarChartGroupData> _buildBarGroups() {
    final groups = <BarChartGroupData>[];

    int index = 0;
    for (final entry in groupData.entries) {
      final value = entry.value;
      final color = value >= 0 ? Colors.blue : Colors.red;

      groups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value,
              color: color,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );

      index++;
    }

    return groups;
  }

  double _getMaxValue() {
    if (groupData.isEmpty) return 100;

    double maxValue = 0;
    for (final value in groupData.values) {
      if (value > maxValue) {
        maxValue = value;
      }
    }

    return maxValue == 0 ? 100 : maxValue;
  }

  double _getMinValue() {
    if (groupData.isEmpty) return -100;

    double minValue = 0;
    for (final value in groupData.values) {
      if (value < minValue) {
        minValue = value;
      }
    }

    return minValue == 0 ? -100 : minValue;
  }

  String _abbreviateGroupName(String name) {
    if (name.length <= 8) return name;

    final words = name.split(' ');
    if (words.length == 1) {
      return '${name.substring(0, 8)}...';
    }

    String result = '';
    for (final word in words) {
      if (word.isNotEmpty) {
        result += word[0];
      }
    }

    return result.length <= 8 ? result : '${result.substring(0, 8)}...';
  }
}
