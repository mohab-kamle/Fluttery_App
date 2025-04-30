import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart'; // Define a Hive Task model similar to Habit
import '../widgets/themes.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late Box<Task> tasksBox;

  @override
  void initState() {
    super.initState();
    tasksBox = Hive.box<Task>('tasks');
  }

  void _showTaskDialog({Task? task, int? index}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    DateTime selectedDate = task?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(task == null ? 'Add Task' : 'Edit Task'),
            content: StatefulBuilder(
              builder:
                  (context, setModalState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task Title',
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: Text(
                          'Due: ${DateFormat.yMMMd().format(selectedDate)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
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
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId == null || titleController.text.trim().isEmpty) {
                    return;
                  }

                  // final newTask = Task(
                  //   userId: userId,
                  //   title: titleController.text.trim(),
                  //   description:
                  //       '', // Add empty description or get it from user input
                  //   date: selectedDate,
                  //   time: DateFormat('HH:mm:ss').format(DateTime.now()),
                  //   priority:
                  //       'Medium', // Replace with appropriate priority value
                  //   done: task?.done ?? false,
                  // );

                  // if (task == null) {
                  //   tasksBox.add(newTask);
                  // } else {
                  //   tasksBox.put(task.key, newTask);
                  // }

                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text('Not logged in'));

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: ValueListenableBuilder(
        valueListenable: tasksBox.listenable(),
        builder: (context, Box<Task> box, _) {
          final userTasks =
              box.values
                  .where((task) => task.userId == currentUser.uid)
                  .toList();

          if (userTasks.isEmpty) {
            return const Center(child: Text('No tasks found.'));
          }

          return ListView.builder(
            itemCount: userTasks.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final task = userTasks[index];

              return Slidable(
                key: Key(task.key.toString()),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed:
                          (_) => _showTaskDialog(task: task, index: index),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (_) {
                        task.delete();
                        setState(() {});
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                  tileColor:
                      task.done ?? false
                          ? Colors.green.shade100
                          : AppColors.primaryLight,
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration:
                          (task.done ?? false)
                              ? TextDecoration.lineThrough
                              : null,
                    ),
                  ),
                  subtitle: Text(
                    'Due: ${DateFormat.yMMMd().format(task.date)}',
                  ),
                  trailing: Checkbox(
                    value: task.done,
                    onChanged: (value) {
                      task.done = value!;
                      task.save();
                      setState(() {});
                    },
                  ),
                  onTap:
                      () => setState(() => task.done = !(task.done ?? false)),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showTaskDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                final tasks =
                    tasksBox.values
                        .where((task) => task.userId == currentUser.uid)
                        .toList();
                if (tasks.isNotEmpty) _showTaskDialog(task: tasks.first);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                final keys =
                    tasksBox.keys.where((key) {
                      final task = tasksBox.get(key);
                      return task?.userId == currentUser.uid;
                    }).toList();
                for (final key in keys) {
                  tasksBox.delete(key);
                }
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
