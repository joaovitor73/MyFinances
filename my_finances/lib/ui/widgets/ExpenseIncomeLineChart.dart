import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseIncomeLineChart extends StatelessWidget {
  final List<double> expenses;
  final List<double> incomes;

  const ExpenseIncomeLineChart({
    super.key,
    required this.expenses,
    required this.incomes,
  });

  void validateData() {
    if (expenses.length != incomes.length) {
      throw ArgumentError(
          'expenses and incomes lists must have the same length');
    }
  }

  List<FlSpot> generateSpots(List<double> data) {
    return data.asMap().entries.map((entry) {
      int index = entry.key;
      double value = entry.value;
      return FlSpot(index.toDouble(), value);
    }).toList();
  }

  List<String> generateMonthLabels(int dataLength) {
    List<String> monthLabels = [];
    for (int i = 0; i < dataLength; i++) {
      final now =
          DateTime.now().subtract(Duration(days: (dataLength - 1 - i) * 30));
      monthLabels.add(DateFormat('MMM').format(now));
    }
    return monthLabels;
  }

  @override
  Widget build(BuildContext context) {
    validateData();

    List<double> lastThreeMonthsExpenses = expenses.sublist(
      expenses.length > 3 ? expenses.length - 3 : 0,
    );
    List<double> lastThreeMonthsIncomes = incomes.sublist(
      incomes.length > 3 ? incomes.length - 3 : 0,
    );

    List<FlSpot> expenseSpots = generateSpots(lastThreeMonthsExpenses);
    List<FlSpot> incomeSpots = generateSpots(lastThreeMonthsIncomes);

    List<String> monthLabels =
        generateMonthLabels(lastThreeMonthsExpenses.length);

    return AspectRatio(
      aspectRatio: 1.7, // Ajustando a proporção para centralizar o gráfico
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: const Color(0xff232d37),
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value >= monthLabels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 2.0,
                            right: 40,
                            left: 20), // Adicionando espaço para os títulos
                        child: Text(
                          monthLabels[value.toInt()],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                    interval: 1,

                    //margin:
                    // 16, // Aumentando a margem do eixo X para evitar que os títulos sejam cortados
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      );
                    },
                    //margin:
                    // 8, // Adicionando margem para que o eixo Y não se sobreponha aos valores
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              minX: 0,
              maxX: (lastThreeMonthsExpenses.length - 1).toDouble(),
              minY: 0,
              maxY: [
                    ...lastThreeMonthsExpenses,
                    ...lastThreeMonthsIncomes,
                  ].reduce((a, b) => a > b ? a : b) +
                  15, // Ajustando a altura para que o gráfico não corte o topo do eixo Y
              lineBarsData: [
                LineChartBarData(
                  spots: expenseSpots,
                  isCurved: true,
                  color: Colors.red[900]!,
                  barWidth: 4,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.red.withOpacity(0.3),
                  ),
                  dotData: const FlDotData(show: true),
                  isStrokeCapRound: true,
                  curveSmoothness: 0.2,
                ),
                LineChartBarData(
                  spots: incomeSpots,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 4,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.withOpacity(0.3),
                  ),
                  dotData: const FlDotData(show: true),
                  isStrokeCapRound: true,
                  curveSmoothness: 0.2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
