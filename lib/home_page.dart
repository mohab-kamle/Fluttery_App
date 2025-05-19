import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/pomodoro_page.dart';
import 'package:flutter_at_akira_menai/habits_page.dart';
import 'package:flutter_at_akira_menai/main.dart';
import 'package:flutter_at_akira_menai/models/habit_model.dart';
import 'package:flutter_at_akira_menai/models/task_model.dart';
import 'package:flutter_at_akira_menai/providers/theme_provider.dart';
import 'package:flutter_at_akira_menai/widgets/qoutes_services.dart';
import 'package:flutter_at_akira_menai/widgets/themes.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  int numberOfTotalHabits = 0;
  double habitProgress = 0.0;
  List<Task> todayTasks = [];
  int pomoHours = 0;
  int pomoMinutes = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Hive.openBox<Habit>('habits');
      await Hive.openBox<Task>('tasks');
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
    final totalMinutes = (totalFocusTime + totalRestTime) ~/ 60;
    if (!mounted) return;
    setState(() {
      pomoHours = totalMinutes ~/ 60;
      pomoMinutes = totalMinutes % 60;
    });
  }

  Future<void> calculateCompletedHabits() async {
    final habitBox = Hive.box<Habit>('habits');
    int completedCount = 0;
    for (int i = 0; i < habitBox.length; i++) {
      final habit = habitBox.getAt(i);
      if (habit != null &&
          habit.lastCompletedDate != null &&
          isSameDay(habit.lastCompletedDate!, DateTime.now())) {
        completedCount++;
      }
    }
    if (!mounted) return;
    setState(() {
      numberOfTotalHabits = habitBox.length;
      numberOfCompletedHabits = completedCount;
      habitProgress =
          numberOfTotalHabits > 0 ? completedCount / numberOfTotalHabits : 0.0;
    });
  }

  Future<void> loadQuote() async {
    final fetchedQuote = await QuoteService.fetchQuoteOfTheDay();
    if (!mounted) return;
    setState(() {
      quote = fetchedQuote ?? 'Stay motivated!';
    });
  }

  void loadTodayTasks() {
    final box = Hive.box<Task>('tasks');
    final today = DateTime.now();
    final tasksToday =
        box.values
            .where((task) => isSameDay(task.date, today) && task.done == true)
            .toList();
    if (!mounted) return;
    setState(() {
      todayTasks = tasksToday;
    });
  }

  String getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Good Morning!";
    if (hour >= 12 && hour < 17) return "Good Afternoon!";
    if (hour >= 17 && hour < 21) return "Good Evening!";
    return "Good Night!";
  }

  String getFormattedDate() {
    return DateFormat.yMMMMEEEEd().format(DateTime.now());
  }

  Widget _summaryItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(text)],
      ),
    );
  }

  Widget _quickActionButton(
    IconData icon,
    String label,
    VoidCallback onTap,
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskBox = Hive.box<Task>('tasks');
    final today = DateTime.now();
    final allTodayTasks =
        taskBox.values.where((task) => isSameDay(task.date, today)).toList();
    final completedToday =
        allTodayTasks.where((task) => task.done == true).toList();

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
                            style: const TextStyle(
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
                                        children: [
                                          _summaryItem(
                                            Icons.check_circle,
                                            '${allTodayTasks.length} Tasks Today',
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
                              _buildProgressCircle(
                                context,
                                completedToday.length,
                                allTodayTasks.length, // here the problem of showing 2 tasks even there are no tasks today
                                'Tasks',
                                Colors.blue,
                              ),
                              _buildProgressCircle(
                                context,
                                numberOfCompletedHabits,
                                numberOfTotalHabits,
                                'Habits',
                                themeProvider.isDarkMode
                                    ? Colors.amberAccent
                                    : Colors.amberAccent.shade700,
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
                          const SizedBox(height: 30),
                          Text(
                            "Recent Activity",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          ValueListenableBuilder(
                            valueListenable:
                                Hive.box<Task>('tasks').listenable(),
                            builder: (context, Box<Task> taskBox, _) {
                              final completedTasksToday =
                                  taskBox.values
                                      .where(
                                        (task) =>
                                            task.done == true &&
                                            isSameDay(task.date, today),
                                      )
                                      .toList();

                              // Get completed habits
                              final habitBox = Hive.box<Habit>('habits');
                              final completedHabitsToday =
                                  habitBox.values
                                      .where(
                                        (habit) =>
                                            habit.lastCompletedDate != null &&
                                            isSameDay(
                                              habit.lastCompletedDate!,
                                              today,
                                            ),
                                      )
                                      .toList();

                              if (completedTasksToday.isEmpty &&
                                  completedHabitsToday.isEmpty) {
                                return Card(
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
                                            "No tasks or habits completed today yet.",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children: [
                                  // Completed Tasks Section
                                  if (completedTasksToday.isNotEmpty) ...[
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.task_alt,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                "Completed Tasks Today",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children:
                                          completedTasksToday.map((task) {
                                            return Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.celebration,
                                                      color: Colors.green,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        "Completed: ${task.title}",
                                                        style: const TextStyle(
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

                                  // Completed Habits Section
                                  if (completedHabitsToday.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.holiday_village,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                "Completed Habits Today",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children:
                                          completedHabitsToday.map((habit) {
                                            return Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.deepOrangeAccent,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        "Completed: ${habit.title}",
                                                        style: const TextStyle(
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
                                ],
                              );
                            },
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle(
    BuildContext context,
    int completed,
    int total,
    String label,
    Color color,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: CircularProgressIndicator(
            value: total == 0 ? 0 : completed / total,
            strokeWidth: 10,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Text(
          "$completed / $total\n$label",
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
