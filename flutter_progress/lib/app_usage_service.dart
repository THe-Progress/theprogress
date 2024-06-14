import 'package:usage_stats/usage_stats.dart';
import 'package:device_apps/device_apps.dart';

class UsageStatsResult {
  final Map<String, UsageInfo> usageInfoMap;
  final List<Application> installedApps;

  UsageStatsResult({
    required this.usageInfoMap,
    required this.installedApps,
  });
}

Future<UsageStatsResult> fetchUsageStatsAndApps() async {
  DateTime endDate = DateTime.now();
  DateTime startDate = endDate.subtract(const Duration(days: 1));

  // Query usage stats
  List<UsageInfo> usageInfoList =
      await UsageStats.queryUsageStats(startDate, endDate);

  // Create a map for quick lookup
  Map<String, UsageInfo> usageInfoMap = {
    for (var v in usageInfoList) v.packageName!: v,
  };

  // Get installed apps
  List<Application> installedApps = await DeviceApps.getInstalledApplications(
    includeSystemApps: false,
    includeAppIcons: true,
    onlyAppsWithLaunchIntent: true,
  );

  return UsageStatsResult(
    usageInfoMap: usageInfoMap,
    installedApps: installedApps,
  );
}

Future<int> getTotalTimeInForeground(
    String packageName, DateTime startTime, DateTime endTime) async {
  List<UsageInfo> usageInfoList =
      await UsageStats.queryUsageStats(startTime, endTime);
  int totalTimeInForeground = 0;

  for (var usageInfo in usageInfoList) {
    if (usageInfo.packageName == packageName) {
      totalTimeInForeground += int.parse(usageInfo.totalTimeInForeground!);
    }
  }

  return totalTimeInForeground;
}
