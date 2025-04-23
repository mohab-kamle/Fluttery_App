// ignore: file_names
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<StatefulWidget> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String Title = '';
  String Description = '';
  DateTime Date = DateTime.now(); // Default to the current date
  TimeOfDay Time = TimeOfDay.now(); // Default to the current time
  String Priority = 'Medium'; // Default priority
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the initial value for the date field
    _dateController.text =
        Date.toLocal().toString().split(' ')[0]; // Format as YYYY-MM-DD
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set the initial value for the time field after context is available
    _timeController.text = Time.format(context); // Format as HH:MM AM/PM
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task Title',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter task title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    Title = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter task description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    Description = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  hintText: 'Select date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: Date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      Date = pickedDate;
                      _dateController.text =
                          Date.toLocal().toString().split(' ')[0];
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _timeController,
                decoration: InputDecoration(
                  hintText: 'Select time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: const Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: Time,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      Time = pickedTime;
                      _timeController.text = Time.format(context);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Priority',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: Priority,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items:
                    ['High', 'Medium', 'Low']
                        .map(
                          (priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    Priority = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (Title.isEmpty || Description.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill in all fields')),
            );
            return;
          }

          // Save the task to the database or perform any action
          print(
            'Task Saved: $Title, $Description, $Date, ${Time.format(context)}, $Priority',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task Saved Successfully!')),
          );
        },
        label: const Text('Save Task'),
        icon: const Icon(Icons.save),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
