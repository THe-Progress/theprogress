// streak_details_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class StreakDetailsScreen extends StatefulWidget {
  @override
  _StreakDetailsScreenState createState() => _StreakDetailsScreenState();
}

class _StreakDetailsScreenState extends State<StreakDetailsScreen> {
  late Map<DateTime, List> _streakDays;
  late List<DateTime> _highlightedDays;

  @override
  void initState() {
    super.initState();
    _initializeStreakDays();
  }

  void _initializeStreakDays() {
    _streakDays = {};
    _highlightedDays = _generateStreakDays();
    for (var day in _highlightedDays) {
      _streakDays[day] = ['Streak'];
    }
  }

  List<DateTime> _generateStreakDays() {
    // Generate some example streak days
    List<DateTime> streakDays = [];
    DateTime today = DateTime.now();
    for (int i = 0; i < 10; i++) {
      streakDays.add(today.subtract(Duration(days: i)));
    }
    return streakDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Streak Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) {
                return _streakDays[day] ?? [];
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
