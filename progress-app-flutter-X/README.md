# Progress Project Documentation

The Progress project is an Android application designed to combat procrastination using machine learning, customized notifications, and a reward system. The project is built using Flutter and Dart.

## Packages Used

- `flutter`: The Flutter SDK for building high-quality native experiences for iOS and Android from a single codebase.
- `device_apps`: A Flutter plugin to list installed applications (only Android).
- `usage_stats`: A Flutter plugin to access Android's UsageStatsManager API.
- `shared_preferences`: A Flutter plugin for reading and writing simple key-value pairs.
- `smooth_page_indicator`: A Flutter plugin for custom page indicators with a smoothly animated page transition.
- `flutter_spinkit`: A collection of loading indicators animated with Flutter.

## Dart Files

- `main.dart`: This file contains the `MyApp` and `OnboardingScreen` classes. `MyApp` is the root widget of the application, and `OnboardingScreen` is the widget for the onboarding process. It uses a `PageController` to manage the onboarding pages.
- `mainapp.dart`: This file contains the `MainApp` class, which is the main application widget. It currently displays the selected activities in a list.
- `app_list_item.dart`: This file contains the `AppListItem` class, a `StatelessWidget` that represents an individual application in the list of installed applications. It includes a `formatDuration` function to format the usage duration of the application.
- `app_usage_service.dart`: This file contains the `UsageStatsResult` class and the `fetchUsageStatsAndApps` function. The function fetches usage statistics and installed applications, and the `UsageStatsResult` class is used to encapsulate the result.
- `favorites_service.dart`: This file contains the `FavoritesService` class, which provides functions to get, save, add, and remove favorite applications using the `SharedPreferences` plugin.
- `usage_stats_screen.dart`: This file contains the `UsageStatsScreen` class, a `StatefulWidget` that displays the usage statistics of the installed applications. It uses the `fetchUsageStatsAndApps` function from `app_usage_service.dart` to fetch the data.
- `streak_indicator.dart`: This file contains the `StreakIndicator` class, a `StatelessWidget` that represents a streak indicator in the UI.

## Key Classes and Functions

- `ActivitySelection`: A class in `main.dart` that allows users to select and deselect activities during onboarding.
- `MainApp`: A class in `mainapp.dart` that represents the main application widget.
- `AppListItem`: A class in `app_list_item.dart` that represents an individual application in the list of installed applications.
- `fetchUsageStatsAndApps`: A function in `app_usage_service.dart` that fetches usage statistics and installed applications.
- `FavoritesService`: A class in `favorites_service.dart` that provides functions to get, save, add, and remove favorite applications.
- `UsageStatsScreen`: A class in `usage_stats_screen.dart` that displays the usage statistics of the installed applications.
