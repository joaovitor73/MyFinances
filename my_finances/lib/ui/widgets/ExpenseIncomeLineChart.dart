import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseIncomeLineChart extends StatelessWidget {
  final List<double> expenses;
  final List<double> incomes;

  const ExpenseIncomeLineChart(
      {super.key, required this.expenses, required this.incomes});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 1),
              const FlSpot(1, 1.5),
              const FlSpot(2, 1.4),
              const FlSpot(3, 3.4),
              const FlSpot(4, 2),
              const FlSpot(5, 2.2),
              const FlSpot(6, 1.8),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
