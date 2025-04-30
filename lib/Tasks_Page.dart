import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
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

  void _showTaskDialog({Task? task}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    DateTime selectedDate = task?.date ?? DateTime.now();
    String selectedPriority = task?.priority ?? 'Medium';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(task == null ? 'Add Task' : 'Edit Task'),
            content: StatefulBuilder(
              builder:
                  (context, setModalState) => SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Task Title',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: descriptionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Description',
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
                        DropdownButtonFormField<String>(
                          value: selectedPriority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                          ),
                          items:
                              ['Low', 'Medium', 'High']
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null)
                              setModalState(() => selectedPriority = value);
                          },
                        ),
                      ],
                    ),
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
                  if (userId == null || titleController.text.trim().isEmpty)
                    return;

                  final newTask = Task(
                    userId: userId,
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    date: selectedDate,
                    time: DateFormat('HH:mm').format(DateTime.now()),
                    priority: selectedPriority,
                    done: task?.done ?? false,
                  );

                  if (task == null) {
                    tasksBox.add(newTask);
                  } else {
                    tasksBox.put(task.key, newTask);
                  }

                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _selectTaskToEditOrDelete(String action) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userTasks =
        tasksBox.values
            .where((task) => task.userId == currentUser?.uid)
            .toList();

    if (userTasks.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No tasks to $action.')));
      return;
    }

    showDialog(
      context: context,
      builder:
          (_) => SimpleDialog(
            title: Text('Select Task to $action'),
            children:
                userTasks.map((task) {
                  return SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                      if (action == 'Edit') {
                        _showTaskDialog(task: task);
                      } else {
                        task.delete();
                        setState(() {});
                      }
                    },
                    child: Text(task.title),
                  );
                }).toList(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text('Not logged in'));

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks'), centerTitle: true),
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
                      onPressed: (_) => _showTaskDialog(task: task),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (_) {
                        task.delete(); // Delete the task from Hive
                        setState(() {}); // Rebuild the UI
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color:
                      (task.done ?? false)
                          ? Colors.green.shade50
                          : Theme.of(context).scaffoldBackgroundColor,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration:
                            (task.done ?? false)
                                ? TextDecoration.lineThrough
                                : null,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '📅 ${DateFormat.yMMMd().format(task.date)} • 🔥 ${task.priority}',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall!.color?.withOpacity(0.8),
                        ),
                      ),
                    ),
                    trailing: Checkbox(
                      value: task.done,
                      onChanged: (value) {
                        task.done = value!;
                        task.save(); // Save the updated status to Hive
                        setState(() {}); // Rebuild the UI
                      },
                    ),
                    onTap:
                        () => setState(() {
                          if (task.done != null) {
                            task.done = !task.done!;
                          }
                        }),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showTaskDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _selectTaskToEditOrDelete('Edit'),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _selectTaskToEditOrDelete('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
