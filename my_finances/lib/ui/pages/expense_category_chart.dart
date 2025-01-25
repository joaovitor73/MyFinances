import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseCategoryChart extends StatelessWidget {
  final Map<String, double> data; // Mapa dinâmico de categoria -> total

  const ExpenseCategoryChart({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: _getBarGroups(),
        titlesData: const FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  // Método para obter os BarGroups dinamicamente
  List<BarChartGroupData> _getBarGroups() {
    return data.entries.map((entry) {
      final category = entry.key;
      final value = entry.value;

      return BarChartGroupData(
        x: data.keys
            .toList()
            .indexOf(category), // Dinâmico baseado na posição da categoria
        barRods: [
          BarChartRodData(
            toY: value,
            color: _getCategoryColor(category),
            width: 25,
          ),
        ],
      );
    }).toList();
  }

  // Método dinâmico para atribuir cores com base nas categorias
  Color _getCategoryColor(String category) {
    // Definir cores diferentes dependendo da categoria
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal
    ];

    int index =
        data.keys.toList().indexOf(category); // Obtendo o índice da categoria
    return colors[index % colors.length]; // Garantindo um ciclo de cores
  }
}
