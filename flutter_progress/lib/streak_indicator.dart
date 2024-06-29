import 'package:flutter/material.dart';
import 'streak_details_screen.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'app_data.dart'; // Import the AppData class

//plain streak indicator
class StreakIndicator extends StatefulWidget {
  @override
  _StreakIndicatorState createState() => _StreakIndicatorState();
}

class _StreakIndicatorState extends State<StreakIndicator> {
  List<String> streakMessages = [
    'Way to go!',
    'Awesome progress!',
    "You're incredible!",
    'Wow, unstoppable!',
    'Truly remarkable!',
    "You're phenomenal!",
    'Outstanding work!',
    'You inspire us!',
    'Simply legendary!',
    'Awe-inspiring!',
  ];
  String extraMessage = "";
  List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  List<String> _getOrderedWeekdays() {
    DateTime today = DateTime.now();
    int todayIndex = today.weekday % 7; // Adjust for 0-based index
    List<String> orderedWeekdays = [];

    for (int i = 4; i >= 0; i--) {
      int dayIndex = (todayIndex - i) % 7;
      if (dayIndex < 0) {
        dayIndex += 7;
      }
      orderedWeekdays.add(weekdays[dayIndex]);
    }

    return orderedWeekdays;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    int currentStreak = appData.currentStreak;
    bool isTodayStreakDay = appData.isTodayStreakDay;
    List<String> orderedWeekdays = _getOrderedWeekdays();

    return GestureDetector(
      onTap: () {
        // Navigate to the StreakDetailsScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StreakDetailsScreen()),
        );
      },
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Color.fromRGBO(244, 67, 54, 1), size: 30),
                  const SizedBox(width: 8),
                  Text(
                    '$currentStreak${currentStreak == 1 ? ' Day' : " Days "}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currentStreak >= 46
                    ? streakMessages[9]
                    : streakMessages[currentStreak ~/ 5],
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (index) {
                    bool isStreakDay;
                    if (index == 4) {
                      isStreakDay = isTodayStreakDay;
                    } else if ((index + currentStreak) >=
                        4 + (isTodayStreakDay ? 1 : 0)) {
                      isStreakDay = true;
                    } else {
                      isStreakDay = false;
                    }
                    return Column(
                      children: [
                        Text(
                          orderedWeekdays[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isStreakDay
                                ? Colors.redAccent
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isStreakDay
                                ? Colors.redAccent
                                : Colors.grey[350],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isStreakDay
                                  ? Colors.redAccent!
                                  : Colors.grey[200]!,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isStreakDay
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
