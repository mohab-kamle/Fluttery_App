import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/models/habit_model.dart';
import 'package:flutter_at_akira_menai/navigation_page.dart';
import 'package:flutter_at_akira_menai/widgets/notification_generator.dart';
import 'package:flutter_at_akira_menai/widgets/themes.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_at_akira_menai/widgets/notification_service.dart';

class HabitsPage extends StatefulWidget {
  final NotificationService notificationService;

  const HabitsPage({super.key, required this.notificationService});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  late Box<Habit> habitsBox;
  bool isSelectionMode = false;
  final Set<int> selectedHabitKeys = {};

  @override
  void initState() {
    super.initState();
    habitsBox = Hive.box<Habit>('habits');
  }

  Future<void> scheduleReminder(Habit habit) async {
    if (!habit.reminderEnabled) return;
    debugPrint('Scheduling reminder for ${habit.title} at ${habit.time}');
    // Schedule the notification for 1 hour before the habit time

    final reminderTime = habit.time.subtract(const Duration(hours: 1));

    // Check if the reminder time is in the past
    if (reminderTime.isBefore(DateTime.now())) {
      // If the reminder time is in the past, do not schedule it
      debugPrint('Reminder time is in the past. Not scheduling notification.');
      return;
    }

    debugPrint('Scheduling notification for ${habit.title} at $reminderTime');

    await widget.notificationService.scheduleNotificationDaily(
      habit.key,
      'Hello,Don\'t forget your daily habit !!',
      habit.title,
      reminderTime,
    );
  }

  void _addHabitDialog({Habit? habit}) {
    final titleController = TextEditingController(text: habit?.title ?? '');
    TimeOfDay selectedTime =
        habit != null
            ? TimeOfDay(hour: habit.time.hour, minute: habit.time.minute)
            : TimeOfDay.now();
    bool enableReminder = habit?.reminderEnabled ?? false;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(habit == null ? 'Add Habit' : 'Edit Habit'),
            content: StatefulBuilder(
              builder:
                  (context, setModalState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Habit Name',
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: Text('Time: ${selectedTime.format(context)}'),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setModalState(() => selectedTime = picked);
                          }
                        },
                      ),
                      SwitchListTile(
                        value: enableReminder,
                        onChanged:
                            (value) =>
                                setModalState(() => enableReminder = value),
                        title: const Text('Remind me 1 hour before'),
                      ),
                    ],
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final now = DateTime.now();
                  final time = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  if (habit == null) {
                    final newHabit = Habit(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      time: time,
                      reminderEnabled: enableReminder,
                    );
                    habitsBox.add(newHabit);
                    widget.notificationService.showInstantNotification(newHabit.key, "bravo !" , generateRandomNotification(
                      userName: FirebaseAuth.instance.currentUser?.displayName,
                    ));
                    if (enableReminder) {
                      scheduleReminder(newHabit);
                    }
                  } else {
                    habit.title = titleController.text;
                    habit.time = time;
                    habit.reminderEnabled = enableReminder;
                    habit.save();
                    if (enableReminder) {
                      scheduleReminder(habit);
                    } else {
                      widget.notificationService.cancelNotification(
                        int.parse(habit.id),
                      );
                    }
                  }

                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _toggleHabitCompletion(Habit habit) {
    final today = DateTime.now();
    final isSameDay =
        habit.lastCompletedDate != null &&
        habit.lastCompletedDate!.year == today.year &&
        habit.lastCompletedDate!.month == today.month &&
        habit.lastCompletedDate!.day == today.day;

    if (!isSameDay) {
      if (habit.lastCompletedDate != null &&
          today.difference(habit.lastCompletedDate!).inDays == 1) {
        habit.streak += 1;
      } else {
        habit.streak = 1;
      }
      habit.lastCompletedDate = today;
      habit.save();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSelectionMode ? '${selectedHabitKeys.length} Selected' : 'Habits',
        ),
        leading:
            isSelectionMode
                ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      isSelectionMode = false;
                      selectedHabitKeys.clear();
                    });
                  },
                )
                : IconButton(
                  icon: const Icon(Icons.arrow_left_outlined),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NavigationPage(),
                      ),
                      (route) => false,
                    );
                  },
                ),
        actions:
            isSelectionMode
                ? [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      for (var key in selectedHabitKeys) {
                        final habit = habitsBox.get(key);
                        if (habit != null) {
                          widget.notificationService.cancelNotification(key);
                          habit.delete();
                        }
                      }
                      setState(() {
                        isSelectionMode = false;
                        selectedHabitKeys.clear();
                      });
                    },
                  ),
                ]
                : [],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ValueListenableBuilder(
          valueListenable: habitsBox.listenable(),
          builder: (context, Box<Habit> box, _) {
            final habits = box.values.toList();
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return Slidable(
                  key: Key(habit.id),
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _addHabitDialog(habit: habit),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          widget.notificationService.cancelNotification(
                            habit.key,
                          ); // Cancel notification
                          habit.delete();
                          setState(() {});
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                      SlidableAction(
                        onPressed: (_) => _toggleHabitCompletion(habit),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.check,
                        label: 'Done',
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        isSelectionMode = true;
                        selectedHabitKeys.add(habit.key);
                      });
                    },
                    onTap: () {
                      if (isSelectionMode) {
                        setState(() {
                          if (selectedHabitKeys.contains(habit.key)) {
                            selectedHabitKeys.remove(habit.key);
                            if (selectedHabitKeys.isEmpty) {
                              isSelectionMode = false;
                            }
                          } else {
                            selectedHabitKeys.add(habit.key);
                          }
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color:
                            selectedHabitKeys.contains(habit.key)
                                ? Colors.blue.shade100
                                : AppColors.primaryLight,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade900,
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    habit.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  spacing: 10,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '⏰ ${DateFormat.jm().format(habit.time)}',
                                    ),
                                    if (habit.reminderEnabled)
                                      Text(
                                        '🔔 Reminder On',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const SizedBox(height: 10),
                                Text(
                                  '📅 Last Completed: ${habit.lastCompletedDate != null ? DateFormat.yMMMd().format(habit.lastCompletedDate!) : 'Never'}',
                                ),
                                Text('🔥 Streak: ${habit.streak}'),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabitDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
