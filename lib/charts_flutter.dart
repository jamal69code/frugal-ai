//import 'package:charts_flutter/flutter.dart' as charts;
//
// class ExpenseChart extends StatelessWidget {
//   final List<charts.Series> seriesList;
//   final bool animate;
//
//   ExpenseChart(this.seriesList, {this.animate = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return charts.BarChart(
//       seriesList,
//       animate: animate,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseChart extends StatelessWidget {
  final List<double> expenses;

  const ExpenseChart({Key? key, required this.expenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: expenses.reduce((a, b) => a > b ? a : b) + 500,
          barGroups: expenses.asMap().entries.map((entry) {
            int index = entry.key;
            double value = entry.value;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = ['Jan', 'Feb', 'Mar', 'Apr'];
                  return Text(
                    months[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
        ),
      ),
    );
  }
}
