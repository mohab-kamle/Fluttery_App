import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/Pomodoro_page.dart';
import 'package:flutter_at_akira_menai/habits_page.dart';
import 'package:flutter_at_akira_menai/main.dart';
import 'package:flutter_at_akira_menai/models/habit_model.dart';
import 'package:flutter_at_akira_menai/models/task_model.dart';
import 'package:flutter_at_akira_menai/providers/theme_provider.dart';
import 'package:flutter_at_akira_menai/widgets/qoutes_services.dart';
import 'package:flutter_at_akira_menai/widgets/themes.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? quote;
  int numberOfCompletedHabits = 0;
  int numberOfTotalHabits = Hive.box<Habit>('habits').length;
  double habitProgress = 0.0;
  List<Task> todayTasks = []; // List to store tasks completed today
  late int pomoHours = 0;
  late int pomoMinutes = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Hive.openBox("pomodoro");
      await calculateCompletedHabits();
      await loadQuote();
      await loadPomodoroTime();
      loadTodayTasks();
    });
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> loadPomodoroTime() async {
    final box = Hive.box("pomodoro");
    final totalFocusTime = box.get("totalFocusTime") ?? 0;
    final totalRestTime = box.get("totalRestTime") ?? 0;
    setState(() {
      final totalMinutes = (totalFocusTime + totalRestTime) ~/ 60;
      pomoHours = totalMinutes ~/ 60;
      pomoMinutes = totalMinutes % 60;
    });
  }

  Future<void> calculateCompletedHabits() async {
    int completedCount = 0;
    for (int i = 0; i < numberOfTotalHabits; i++) {
      final habit = Hive.box<Habit>('habits').getAt(i);
      if (habit != null &&
          habit.lastCompletedDate != null &&
          isSameDay(habit.lastCompletedDate!, DateTime.now())) {
        completedCount++;
      }
    }
    setState(() {
      habitProgress =
          numberOfTotalHabits > 0 ? completedCount / numberOfTotalHabits : 0.0;
      numberOfTotalHabits = Hive.box<Habit>('habits').length;
      numberOfCompletedHabits = completedCount;
    });
  }

  Future<void> loadQuote() async {
    final fetchedQuote = await QuoteService.fetchQuoteOfTheDay();
    setState(() {
      quote = fetchedQuote ?? 'Stay motivated!';
    });
  }

  void loadTodayTasks() {
    final box = Hive.box<Task>('tasks');
    final today = DateTime.now();
    final tasksToday =
        box.values
            .cast<Task>()
            .where(
              (task) =>
                  task.date.year == today.year &&
                  task.date.month == today.month &&
                  task.date.day == today.day,
            )
            .toList();
    setState(() {
      todayTasks = tasksToday;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await loadQuote();
          await calculateCompletedHabits();
          loadTodayTasks();
          await loadPomodoroTime();
        },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  quote == null
                      ? Center(
                        child: Lottie.asset(
                          'assets/animations/AnimationLoading.json',
                          width: 200,
                          height: 200,
                        ),
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          SafeArea(
                            child: Center(
                              child: Text(
                                getGreetingMessage(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Today's Motivation",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            quote!,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 20),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      themeProvider.isDarkMode
                                          ? AppColors.primaryDark
                                          : AppColors.primaryLight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        getFormattedDate(),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 15),
                                      Column(
                                        spacing: 10,
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _summaryItem(
                                            Icons.check_circle,
                                            '${todayTasks.length} Tasks Today',
                                          ),
                                          _summaryItem(
                                            Icons.access_time,
                                            'Time Tracked: ${pomoHours}h ${pomoMinutes}m',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: Text(
                              "Task's and Habit's Progress",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 120,
                                    width: 120,
                                    child: CircularProgressIndicator(
                                      value:
                                          todayTasks.length /
                                          (todayTasks.length +
                                              3), // Example: Assume max 5 tasks
                                      strokeWidth: 10,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${todayTasks.length} / ${todayTasks.length + 5} \nTasks",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 120,
                                    width: 120,
                                    child: CircularProgressIndicator(
                                      value: habitProgress,
                                      strokeWidth: 10,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        themeProvider.isDarkMode
                                            ? Colors.amberAccent
                                            : Colors.amberAccent.shade700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$numberOfCompletedHabits/$numberOfTotalHabits\nHabits',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _quickActionButton(
                                Icons.event_repeat_rounded,
                                'Habits',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => HabitsPage(
                                            notificationService:
                                                notificationService,
                                          ),
                                    ),
                                  );
                                },
                                context,
                              ),
                              _quickActionButton(Icons.timer, 'Pomodoro', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PomodoroTimer(),
                                  ),
                                );
                              }, context),
                              _quickActionButton(
                                Icons.bar_chart,
                                'Stats',
                                () {},
                                context,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const SizedBox(height: 30),
                          Text(
                            "Recent Activity",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          todayTasks.isEmpty
                              ? Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.info, color: Colors.grey),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "No tasks completed today yet.",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              : Column(
                                children:
                                    todayTasks.map((task) {
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.celebration,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  "Completed: ${task.title}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

String getGreetingMessage() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) {
    return "Good Morning!";
  } else if (hour >= 12 && hour < 17) {
    return "Good Afternoon!";
  } else if (hour >= 17 && hour < 21) {
    return "Good Evening!";
  } else {
    return "Good Night!";
  }
}

String getFormattedDate() {
  return DateFormat('EEEE, MMMM d').format(DateTime.now());
}

Widget _summaryItem(IconData icon, String label) {
  return Column(
    children: [
      Icon(icon, size: 28),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}

Widget _quickActionButton(
  IconData icon,
  String label,
  VoidCallback onTap,
  BuildContext context,
) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                themeProvider.isDarkMode
                    ? AppColors.primaryDark
                    : AppColors.primaryLight,
          ),
          color:
              themeProvider.isDarkMode
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}
