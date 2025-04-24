import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/widgets/task_modal.dart';

class Taskspage extends StatefulWidget {
  const Taskspage({super.key});

  @override
  State<Taskspage> createState() => _TaskspageState();
}

class _TaskspageState extends State<Taskspage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tasks Page Content'),
            ElevatedButton(
              onPressed: () {
                // Add your button action here

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskPage()),
                );
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
