import 'package:flutter/material.dart';
import 'dart:async';

import 'package:path/path.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PomodoroTimer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PomodoroTimer extends StatefulWidget {
  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  static int Focus = 1;
  static int Break = 1;
  static int workTime = Focus * 60;
  static int breakTime = Break * 60;
  int secondsLeft = workTime;
  Timer? timer;
  bool isRunning = false;
  bool isWorkTime = true;
  
  // time setted to toggle between two states when setting time and when timer starting
  //intial value is false for setting time first 
  bool timeSetted = false;

  String message = "";

  void startTimer() {
    if (timer != null) {
      timer?.cancel();

      setState(() {
        message = "";
        isRunning = true;
      });
    }

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsLeft > 0) {
        setState(() {
          secondsLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          isRunning = false;
          message = isWorkTime ? "Focus session finshed!" : "Break finshed";
          isWorkTime = !isWorkTime;
          secondsLeft = isWorkTime ? workTime : breakTime;
        });
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      secondsLeft = isWorkTime ? workTime : breakTime;
      isRunning = false;
      message = "";
    });
  }

  void cancelTimer() {
    timer?.cancel();
    setState(() {
      secondsLeft = workTime;
      isRunning = false;
      isWorkTime = true;
      message = "";
    });
  }

  String formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Pomodoro Timer")),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!timeSetted) ...[
              Container(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Set Focus and Break Durations in MINUTES!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      onChanged: (value) {
                        Focus = int.tryParse(value) ?? 1;
                        workTime = Focus * 60;
                        if (isWorkTime) secondsLeft = workTime;
                      },
                      style: TextStyle(fontSize: 30),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Focus"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    ":",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      onChanged: (value) {
                        Break = int.tryParse(value) ?? 1;
                        breakTime = Break * 60;
                        if (!isWorkTime) secondsLeft = breakTime;
                      },
                      style: TextStyle(fontSize: 30),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Break"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    timeSetted = true;
                    secondsLeft = isWorkTime ? workTime : breakTime;
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(120, 50),
                ),
                child: Text(
                  "Set",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            ] else ...[
              TextButton(
                onPressed: () {
                  setState(() {
                    timeSetted = false;
                  });
                },
                style: TextButton.styleFrom(fixedSize: Size(50, 50)),
                child: Icon(Icons.arrow_back, size: 30),
              ),
              SizedBox(height: 10),
              Text(
                isWorkTime ? "Focus Time!" : "Let's Break!",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                formatTime(secondsLeft),
                style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              if (!isRunning)
                ElevatedButton(
                  onPressed: startTimer,
                  style: ElevatedButton.styleFrom(fixedSize: Size(120, 50)),
                  child: Text("Start", style: TextStyle(fontSize: 20)),
                )
              else
                ElevatedButton(
                  onPressed: pauseTimer,
                  style: ElevatedButton.styleFrom(fixedSize: Size(120, 50)),
                  child: Text("Pause", style: TextStyle(fontSize: 20)),
                ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: resetTimer,
                style: ElevatedButton.styleFrom(fixedSize: Size(120, 50)),
                child: Text("Reset", style: TextStyle(fontSize: 20)),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: cancelTimer,
                style: ElevatedButton.styleFrom(fixedSize: Size(120, 50)),
                child: Text("Cancel", style: TextStyle(fontSize: 20)),
              ),
              if (message.isNotEmpty) ...[
                SizedBox(height: 20),
                Text(
                  message,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ],
        ),
      ),
    ),
  );
}
}

/* // when the set time pressed
            TextButton(
                onPressed: () {
                  setState(() {
                    timeSetted = false;
                  });
                },
                style: TextButton.styleFrom(fixedSize: Size(50, 50)),
                child: Icon(Icons.arrow_back, size: 30),
              ),
              SizedBox(height: 10),
              Text(
                isWorkTime ? "Focus Time!" : "Let's Break",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                formatTime(secondsLeft),
                style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              if (!isRunning) // Strat Button
                ElevatedButton(
                  onPressed: startTimer,
                  style: ElevatedButton.styleFrom(fixedSize: Size(120, 50)),
                  child: Text("Start", style: TextStyle(fontSize: 20)),
                )
              else // Pause Button
                ElevatedButton(
                  onPressed: pauseTimer,
                  style: ElevatedButton.styleFrom(fixedSize: Size(120, 50)),
                  child: Text("Pause", style: TextStyle(fontSize: 20)),
                ),
              // Reset Button
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: resetTimer,
                style: ElevatedButton.styleFrom(fixedSize: Size(120, 50)),
                child: Text("Reset", style: TextStyle(fontSize: 20)),
              ),
              // Cancel button
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: cancelTimer,
                style: ElevatedButton.styleFrom(fixedSize: Size(120, 50)),
                child: Text("Cancel", style: TextStyle(fontSize: 20)),
              ),
 */


/* // when pomodoro canceled
            Container(
              padding: EdgeInsets.all(15),
              child: Text(
                "Set Focus and Break Durations in MINUTES!",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    onChanged: (value) {
                      Focus = int.parse(value);
                    },
                    style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Focus"),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    ":",
                    style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 100,
                  child: TextField(
                    onChanged: (value) {
                      Break = int.parse(value);
                    },
                    style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Break"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  timeSeted = true;
                });
              },
              style: ElevatedButton.styleFrom(minimumSize: Size(120, 50)),
              child: Text(
                "Set",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
*/