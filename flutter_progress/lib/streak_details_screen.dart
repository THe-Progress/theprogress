import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:provider/provider.dart';
import 'package:progress/app_data.dart';
import 'package:progress/usage_bar_graph.dart';

class StreakDetailsScreen extends StatefulWidget {
  @override
  _StreakDetailsScreenState createState() => _StreakDetailsScreenState();
}

class _StreakDetailsScreenState extends State<StreakDetailsScreen> {
  late Map<DateTime, List> _streakDays;
  late String _selectedApp;

  @override
  void initState() {
    super.initState();
    _initializeStreakDays();
    final appData = Provider.of<AppData>(context, listen: false);
    _selectedApp = appData.installedApps.isNotEmpty
        ? appData.installedApps.first.packageName!
        : '';
  }

  void _initializeStreakDays() {
    final appData = Provider.of<AppData>(context, listen: false);
    _streakDays = _generateStreakDays(appData);
  }

  Map<DateTime, List> _generateStreakDays(AppData appData) {
    Map<DateTime, List> streakDays = {};
    DateTime today = DateTime.now();
    if (appData.isTodayStreakDay) {
      for (int i = 0; i <= appData.currentStreak; i++) {
        DateTime streakDay = DateTime(today.year, today.month, today.day)
            .subtract(Duration(days: i));
        streakDays[streakDay] = ['Streak'];
      }
    } else {
      for (int i = 0; i < appData.currentStreak; i++) {
        DateTime streakDay = DateTime(today.year, today.month, today.day)
            .subtract(Duration(days: i + 1));
        streakDays[streakDay] = ['Streak'];
      }
    }
    return streakDays;
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

    return Scaffold(
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CalendarCarousel<Event>(
              onDayPressed: (DateTime date, List<Event> events) {},
              weekendTextStyle: TextStyle(
                color: Colors.black,
              ),
              thisMonthDayBorderColor: Colors.transparent,
              weekFormat: false,
              height: 390.0,
              selectedDayButtonColor: Colors.transparent,
              selectedDateTime: DateTime.now(),
              selectedDayBorderColor: Colors.transparent,
              daysHaveCircularBorder: false,
              todayTextStyle: TextStyle(
                color: Colors.white,
              ),
              customDayBuilder: (
                bool isSelectable,
                int index,
                bool isSelectedDay,
                bool isToday,
                bool isPrevMonthDay,
                TextStyle textStyle,
                bool isNextMonthDay,
                bool isThisMonthDay,
                DateTime day,
              ) {
                if (_streakDays.containsKey(day)) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 25.0,
                      ),
                    ),
                  );
                } else {
                  return null;
                }
              },
              todayBorderColor: Colors.blue,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedApp,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedApp = newValue!;
                });
              },
              items: appData.installedApps
                  .map<DropdownMenuItem<String>>((Application app) {
                return DropdownMenuItem<String>(
                  value: app.packageName!,
                  child: Text(
                      app.appName), // Show app name instead of package name
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ),
            const SizedBox(height: 16),
            Text('App Usage', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: UsageBarGraph(
                selectedApp: _selectedApp, // Pass number of days
              ),
            ),
          ],
        ),
      ),
    );
  }
}
