import 'package:flutter/material.dart';
import 'package:progress/fcm-notify.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mainapp.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final String _fcmToken;
  String _topic = "bitch";

  @override
  void initState() {
    super.initState();
    NotificationService().initialize().then((token) {
      setState(() {
        _fcmToken = token!;
      });
      if (token != null) {
        NotificationService().subscribeToTopic(_topic);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Progress',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Text("helloworld"),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final List<Widget> _onboardingScreens = [
    const OnboardingPage(
      title: 'Welcome to Progress!',
      description:
          'This app is designed to help you stay focused and achieve your goals.',
    ),
    const OnboardingPage(
      title: 'Benefits Highlights',
      description:
          'Track your progress and stay motivated with personalized reminders and rewards.',
    ),
    const OnboardingPage(
      title: 'User Permissions',
      description:
          'Progress needs permission to send you notifications to keep you on track.',
    ),
  ];
  Map<String, TimeOfDay> selectedActivities = {};

  @override
  void initState() {
    super.initState();
    selectedActivities = {};
  }

  void _onActivitySelectionChanged() {
    // Schedule the state change after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void _navigateToMainApp(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainApp(
            selectedActivities: selectedActivities,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                ..._onboardingScreens,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Personalization',
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Select your preferred activities and set time',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    ActivitySelection(
                      selectedActivities: selectedActivities,
                      onSelectionChanged: _onActivitySelectionChanged,
                    ),
                    if (selectedActivities.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 24.0),
                          ElevatedButton(
                            onPressed: () => _navigateToMainApp(context),
                            child: const Text('Get Started'),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: _onboardingScreens.length + 1,
            effect: const ScrollingDotsEffect(
              activeDotColor: Colors.blue,
              dotColor: Colors.grey,
              dotHeight: 10,
              dotWidth: 10,
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;

  const OnboardingPage({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}

const List<String> availableActivities = [
  'Coding',
  'Exercise',
  'Learning',
  'Reading',
  'Writing',
  'Meditation',
  'Cooking',
  'Gardening',
];

class ActivitySelection extends StatefulWidget {
  final Map<String, TimeOfDay> selectedActivities;
  final VoidCallback onSelectionChanged;

  const ActivitySelection({
    super.key,
    required this.selectedActivities,
    required this.onSelectionChanged,
  });

  @override
  State<ActivitySelection> createState() => _ActivitySelectionState();
}

class _ActivitySelectionState extends State<ActivitySelection> {
  Future<void> _selectTime(String activity) async {
    final TimeOfDay initialTime = TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          widget.selectedActivities[activity] = pickedTime;
          widget.onSelectionChanged();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: availableActivities.map((activity) {
        return FilterChip(
          label: Text(activity),
          selected: widget.selectedActivities.containsKey(activity),
          onSelected: (isSelected) {
            if (isSelected) {
              _selectTime(activity);
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  widget.selectedActivities.remove(activity);
                  widget.onSelectionChanged();
                });
              });
            }
          },
        );
      }).toList(),
    );
  }
}
