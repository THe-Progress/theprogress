import 'package:usage_stats/usage_stats.dart';

/// ForegroundAppInfo
///
/// This class provides a method to get the current foreground app.
///
/// Usage Example:
///
/// ```dart
/// import 'foreground_app_info.dart';
///
/// void main() async {
///   String currentApp = await ForegroundAppInfo.getCurrentForegroundApp();
///   print('Current foreground app: $currentApp');
/// }
/// ```
///
/// Ensure that the required permissions for usage stats are granted:
/// - android.permission.PACKAGE_USAGE_STATS
///
/// You may need to guide the user to enable the permission in the settings.
///
/// Example for checking and requesting permissions:
///
/// ```dart
/// import 'package:usage_stats/usage_stats.dart';
/// import 'package:permission_handler/permission_handler.dart';
///
/// Future<bool> _checkAndRequestUsagePermission() async {
///   bool isGranted = (await UsageStats.checkUsagePermission()) ?? false;
///   if (!isGranted) {
///     // Open the usage access settings page
///     await openAppSettings();
///   }
///   // Re-check if the permission is granted after opening settings
///   isGranted = (await UsageStats.checkUsagePermission()) ?? false;
///   return isGranted;
/// }
/// ```
class ForegroundAppInfo {
  static Future<String> getCurrentForegroundApp() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    try {
      List<UsageInfo> usageInfoList =
          await UsageStats.queryUsageStats(startOfDay, now);
      usageInfoList.sort((a, b) => int.parse(b.lastTimeUsed ?? '0')
          .compareTo(int.parse(a.lastTimeUsed ?? '0')));
      return usageInfoList.isNotEmpty
          ? usageInfoList.first.packageName ?? "Unknown"
          : "Unknown";
    } catch (e) {
      print('Error querying current app: $e');
      return "Unknown";
    }
  }
}
