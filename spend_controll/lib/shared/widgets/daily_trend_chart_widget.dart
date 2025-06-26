import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../modules/report/model/daily_total.dart';

class DailyTrendChartWidget extends StatelessWidget {
  final List<DailyTotal> dailyTotals;

  const DailyTrendChartWidget({super.key, required this.dailyTotals});

  @override
  Widget build(BuildContext context) {
    if (dailyTotals.isEmpty) {
      return _buildEmptyState();
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < dailyTotals.length; i++) {
      final total = dailyTotals[i];
      spots.add(FlSpot(i.toDouble(), total.income - total.expense));
    }

    final maxY = (dailyTotals
            .map((e) => e.income - e.expense)
            .fold<double>(0, (prev, v) => v > prev ? v : prev)) *
        1.2;
    final minY = (dailyTotals
            .map((e) => e.income - e.expense)
            .fold<double>(0, (prev, v) => v < prev ? v : prev)) *
        1.2;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minY: minY == 0 ? -100 : minY,
            maxY: maxY == 0 ? 100 : maxY,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < dailyTotals.length) {
                      final date = dailyTotals[index].date;
                      return Text(
                        '${date.day}',
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: (maxY.abs() + minY.abs()) / 5,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              ),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 2,
                color: Theme.of(context).primaryColor,
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
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
              Icons.show_chart,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum dado no período',
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
}
