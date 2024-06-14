import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mainapp.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//has onboarding screen and calls mainapp.dart when get started is called
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FCMToken = await messaging.getToken();
  print("token, ${FCMToken}");
  await messaging.setAutoInitEnabled(true);
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: true,
  );

  // Handle the settings response
  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted permission');
  } else {
    print('User declined or has not accepted permission');
  }
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message while in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // Subscribe to a topic
    _subscribeToTopic('xxx');
  }

  void _subscribeToTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Progress',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const OnboardingScreen(),
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
    // Welcome Screen
    const OnboardingPage(
      title: 'Welcome to Progress!',
      description:
          'This app is designed to help you stay focused and achieve your goals.',
    ),
    // Benefits Highlights
    const OnboardingPage(
      title: 'Benefits Highlights',
      description:
          'Track your progress and stay motivated with personalized reminders and rewards.',
    ),
    // User Permissions
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
    setState(() {});
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainApp(
                                    selectedActivities: selectedActivities,
                                  ),
                                ),
                              );
                            },
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
            count: _onboardingScreens.length + 1, // Added 1 for the new page
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
  // Add more activities as needed
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
      setState(() {
        widget.selectedActivities[activity] = pickedTime;
        widget.onSelectionChanged();
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
              setState(() {
                widget.selectedActivities.remove(activity);
                widget.onSelectionChanged();
              });
            }
          },
        );
      }).toList(),
    );
  }
}
