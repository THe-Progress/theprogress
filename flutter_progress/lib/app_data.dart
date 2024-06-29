import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';

class AppData extends ChangeNotifier {
  Map<String, TimeOfDay> _selectedActivities = {};
  Map<String, UsageInfo> _usageInfoMap = {};
  List<Application> _installedApps = [];
  int _currentStreak = 20;
  bool _isTodayStreakDay = true;

  Map<String, TimeOfDay> get selectedActivities => _selectedActivities;
  Map<String, UsageInfo> get usageInfoMap => _usageInfoMap;
  List<Application> get installedApps => _installedApps;
  int get currentStreak => _currentStreak;
  bool get isTodayStreakDay => _isTodayStreakDay;

  void setSelectedActivities(Map<String, TimeOfDay> selectedActivities) {
    _selectedActivities = selectedActivities;
    notifyListeners();
  }

  void setUsageInfoMap(Map<String, UsageInfo> usageInfoMap) {
    _usageInfoMap = usageInfoMap;
    notifyListeners();
  }

  void setInstalledApps(List<Application> installedApps) {
    _installedApps = installedApps;
    notifyListeners();
  }

  void setCurrentStreak(int streak) {
    _currentStreak = streak;
    notifyListeners();
  }

  void setIsTodayStreakDay(bool isTodayStreakDay) {
    _isTodayStreakDay = isTodayStreakDay;
    notifyListeners();
  }
}
