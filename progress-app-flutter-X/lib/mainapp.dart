// mainapp.dart
import 'package:flutter/material.dart';
import 'usage_stats_screen.dart';

class MainApp extends StatelessWidget {
  final Map<String, TimeOfDay> selectedActivities;

  const MainApp({required this.selectedActivities});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic),
          bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      home: UsageStatsScreen(),
    );
  }
}
