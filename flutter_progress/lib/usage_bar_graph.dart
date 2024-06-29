import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:progress/app_usage_service.dart';

class UsageBarGraph extends StatelessWidget {
  final String selectedApp;
  final int noOfDays = 7;

  UsageBarGraph({required this.selectedApp});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, int>>(
      future: getDailyUsageForApp(selectedApp, noOfDays),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          Map<DateTime, int> dailyUsage = snapshot.data ?? {};

          // List<BarChartGroupData> barGroups =
          //     dailyUsage.entries.toList().reversed.map((entry) {
          //   double usageHours = entry.value / 3600000; // Convert ms to hours
          //   return BarChartGroupData(
          //     x: entry.key.day,
          //     barRods: [
          //       BarChartRodData(
          //         y: usageHours,
          //         colors: [Colors.purple[800]!],
          //         width: 16,
          //         borderRadius: BorderRadius.circular(4),
          //       ),
          //     ],
          //   );
          // }).toList();

          // double maxY = barGroups.isNotEmpty
          //     ? barGroups
          //         .map((g) => g.barRods[0].y)
          //         .reduce((a, b) => a > b ? a : b)
          //     : 1;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            // child: BarChart(
            //   BarChartData(
            //     barGroups: barGroups,
            //     titlesData: FlTitlesData(
            //       leftTitles: SideTitles(
            //         showTitles: true,
            //         getTitles: (value) {
            //           if (value % 1 == 0) {
            //             return '${value.toInt()}h';
            //           } else if (maxY < 1) {
            //             return '${(value * 60).toInt()}m';
            //           }
            //           return '';
            //         },
            //         margin: 1,
            //       ),
            //       topTitles: SideTitles(showTitles: false),
            //       rightTitles: SideTitles(showTitles: false),
            //     ),
            //     borderData: FlBorderData(
            //       show: false,
            //     ),
            //     gridData: FlGridData(
            //       drawVerticalLine: false,
            //       drawHorizontalLine: true,
            //       horizontalInterval: 1,
            //       getDrawingHorizontalLine: (value) => FlLine(
            //         color: Colors.grey[300]!,
            //         strokeWidth: .3,
            //       ),
            //     ),
            //     barTouchData: BarTouchData(
            //       enabled: false,
            //       touchTooltipData: BarTouchTooltipData(
            //         tooltipPadding: EdgeInsets.zero,
            //         tooltipBgColor: Colors.transparent,
            //         getTooltipItem: (group, groupIndex, rod, rodIndex) => null,
            //       ),
            //     ),
            //     alignment: BarChartAlignment.spaceAround,
            //     maxY: maxY < 1
            //         ? maxY * 60
            //         : maxY, // Scale up for minutes if < 1hr
            //   ),
            // ),
            child: Text("Nothing here"),
          );
        }
      },
    );
  }

  Future<Map<DateTime, int>> getDailyUsageForApp(
      String packageName, int noOfDays) async {
    Map<DateTime, int> dailyUsage = {};
    DateTime endDate = DateTime.now();
    int maxUsagePerDay = 10 * 60 * 60 * 1000;

    for (int i = 0; i < noOfDays; i++) {
      DateTime day = endDate.subtract(Duration(days: i));
      DateTime startOfDay = DateTime(day.year, day.month, day.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      int totalTimeInForeground =
          await getTotalTimeInForeground(packageName, startOfDay, endOfDay);

      if (totalTimeInForeground > maxUsagePerDay) {
        totalTimeInForeground = maxUsagePerDay;
      }

      dailyUsage[startOfDay] = totalTimeInForeground;
    }

    return dailyUsage;
  }
}
