import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/widgets/themes.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

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

  // Show Task Dialog
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
                            if (value != null) {
                              setModalState(() => selectedPriority = value);
                            }
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
                  if (userId == null || titleController.text.trim().isEmpty) {
                    return;
                  }

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

  // Select Task to Edit or Delete
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

  // Build Method
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text('Not logged in'));

    return Scaffold(
      appBar: AppBar(
  title: const Text('My Tasks'),
  centerTitle: true,
  elevation: 3,
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(50.0), // Height of the bottom section
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.add, size: 28 , color: AppColors.backgroundLight,),
            onPressed: () => _showTaskDialog(),
            tooltip: "Add Task",
          ),
          IconButton(
            icon: const Icon(Icons.edit_note, size: 28, color: AppColors.backgroundLight,),
            onPressed: () => _selectTaskToEditOrDelete('Edit'),
            tooltip: "Edit Task",
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 28, color: AppColors.backgroundLight,),
            onPressed: () => _selectTaskToEditOrDelete('Delete'),
            tooltip: "Delete Task",
          ),
        ],
      ),
    ),
  ),
),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: ValueListenableBuilder(
              valueListenable: tasksBox.listenable(),
              builder: (context, Box<Task> box, _) {
                final userTasks = box.values
                    .where((task) => task.userId == currentUser.uid)
                    .toList();

                if (userTasks.isEmpty) {
                  return const Center(
                    child: Text(
                      '🎉 No tasks yet!\nTap "+" to add one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
  itemCount: userTasks.length,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  itemBuilder: (context, index) {
    final task = userTasks[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Slidable(
        key: Key(task.key.toString()),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _showTaskDialog(task: task),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (_) {
                task.delete();
                setState(() {});
              },
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: (task.done ?? false)
              ? (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primaryDark
                  : AppColors.primaryLight.withAlpha(220))
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.white),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: (task.done ?? false)
                    ? TextDecoration.lineThrough
                    : null,
                color: (task.done ?? false)
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.white)
                    : null,
              ),
            ),
            subtitle: Text(
              '${DateFormat.yMMMd().format(task.date)} • ${task.priority}',
              style: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.white70),
              ),
            ),
            trailing: Checkbox.adaptive(
              fillColor: WidgetStatePropertyAll(Colors.blue),
              checkColor: Colors.white,
              value: task.done,
              onChanged: (value) {
                task.done = value!;
                task.save();
                setState(() {});
              },
            ),
            onTap: () {
              task.done = !task.done!;
              task.save();
              setState(() {});
            },
          ),
        ),
      ),
    );
  },
);

              },
            ),
          ),
        ),
      ),
    );
  }
}
