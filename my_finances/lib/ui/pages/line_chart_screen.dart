import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartScreen extends StatefulWidget {
  LineChartScreen({Key? key}) : super(key: key);

  @override
  _LineChartScreenState createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  bool isShowingMainData = true;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xff232d37),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LineChart(
                    isShowingMainData ? sampleData1() : sampleData2(),
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => isShowingMainData = !isShowingMainData),
                child: Text(
                  'Trocar dados',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LineChartData sampleData1() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: titlesData(),
      borderData: borderData(),
      lineBarsData: [lineChartBarData1()],
    );
  }

  LineChartData sampleData2() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: titlesData(),
      borderData: borderData(),
      lineBarsData: [lineChartBarData2()],
    );
  }

  FlTitlesData titlesData() {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 1,
          getTitlesWidget: bottomTitleWidgets,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 1,
          getTitlesWidget: leftTitleWidgets,
        ),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlBorderData borderData() {
    return FlBorderData(
      show: true,
      border: Border.all(color: const Color(0xff37434d), width: 1),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.white, fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Jan';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      default:
        return Container();
    }
    return Text(text, style: style);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.white, fontSize: 10);
    return Text(value.toInt().toString(), style: style);
  }

  LineChartBarData lineChartBarData1() {
    return LineChartBarData(
      isCurved: true,
      color: Colors.blue,
      barWidth: 4,
      belowBarData:
          BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
      spots: const [
        FlSpot(0, 1),
        FlSpot(1, 3),
        FlSpot(2, 2),
      ],
    );
  }

  LineChartBarData lineChartBarData2() {
    return LineChartBarData(
      isCurved: true,
      color: Colors.red,
      barWidth: 4,
      belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.3)),
      spots: const [
        FlSpot(0, 2),
        FlSpot(1, 1.5),
        FlSpot(2, 2.5),
      ],
    );
  }
}
