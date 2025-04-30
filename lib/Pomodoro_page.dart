import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:audioplayers/audioplayers.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  int focus = 1;
  int rest = 1;
  int workTime = 60;
  int restTime = 60;
  int secondsLeft = 60;
  Timer? timer;
  bool isRunning = false;
  bool isWorkTime = true;
  bool timeSetted = false;
  String message = "";

  int totalFocusTime = 0;
  int totalRestTime = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  void resetDailyTime() async {
    var pomo = Hive.box('pomodoro');
    DateTime today = DateTime.now();
    DateTime? lastDate = pomo.get("lastDate") as DateTime?;

    if (lastDate == null ||
        lastDate.year != today.year ||
        lastDate.month != today.month ||
        lastDate.day != today.day) {
      pomo.put("lastDate", today);
      pomo.put("totalFocusTime", 0);
      pomo.put("totalRestTime", 0);
      totalFocusTime = 0;
      totalRestTime = 0;
    } else {
      totalFocusTime = pomo.get("totalFocusTime") ?? 0;
      totalRestTime = pomo.get("totalRestTime") ?? 0;
    }
  }

  void startTimer() {
    var pomo = Hive.box("pomodoro");
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
        _audioPlayer.play(AssetSource('alarm.mp3'));
        setState(() {
          isRunning = false;
          message = isWorkTime ? "Focus session finished!" : "Rest finished!";
          if (isWorkTime) {
            pomo.put("totalFocusTime", pomo.get("totalFocusTime") + workTime);
          } else {
            pomo.put("totalRestTime", pomo.get("totalRestTime") + restTime);
          }
          isWorkTime = !isWorkTime;
          secondsLeft = isWorkTime ? workTime : restTime;
        });
      }
    });
    setState(() {
      isRunning = true;
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
      secondsLeft = isWorkTime ? workTime : restTime;
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
  void initState() {
    super.initState();
    resetDailyTime();
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pomodoro")),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            resetDailyTime();
          });
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!timeSetted) ...[
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              "Set focus and rest Durations",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  onChanged: (value) {
                                    focus = int.tryParse(value) ?? 1;
                                    workTime = focus * 60;
                                    if (isWorkTime) secondsLeft = workTime;
                                  },
                                  style: TextStyle(fontSize: 30),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    focusedBorder: InputBorder.none,
                                    label: Center(child: Text("Focus")),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(":",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 50),textAlign: TextAlign.center,),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  onChanged: (value) {
                                    rest = int.tryParse(value) ?? 1;
                                    restTime = rest * 60;
                                    if (!isWorkTime) secondsLeft = restTime;
                                  },
                                  style: TextStyle(fontSize: 30),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    focusedBorder: InputBorder.none,
                                    label: Center(child: Text("Rest")),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                timeSetted = true;
                                workTime = focus * 60;
                                restTime = rest * 60;
                                secondsLeft = isWorkTime ? workTime : restTime;
                              });
                            },
                            child: Text("Set", style: TextStyle(fontSize: 25)),
                          ),
                        ] else ...[
                          Text(
                            isWorkTime ? "Focus Time!" : "Let's Rest!",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              SizedBox(
                                height: 300,
                                width: 300,
                                child: CircularProgressIndicator(
                                  value:
                                      1 -
                                      (secondsLeft /
                                          (isWorkTime ? workTime : restTime)),
                                  strokeWidth: 5,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                              ),
                              Text(
                                formatTime(secondsLeft),
                                style: TextStyle(
                                  fontSize: 70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            style: ButtonStyle(
                              fixedSize: WidgetStateProperty.all(Size(140, 50)),
                            ),
                            onPressed: isRunning ? pauseTimer : startTimer,
                            child: Text(
                              isRunning ? "Pause" : "Start",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            style: ButtonStyle(
                              fixedSize: WidgetStateProperty.all(Size(140, 50)),
                            ),
                            onPressed: resetTimer,
                            child: Text(
                              "Reset",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            style: ButtonStyle(
                              fixedSize: WidgetStateProperty.all(Size(140, 50)),
                            ),
                            onPressed: () {
                              cancelTimer();
                              setState(() {
                                timeSetted = false;
                              });
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          if (message.isNotEmpty) ...[
                            SizedBox(height: 20),
                            Text(
                              message,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
                isWorkTime ? "focus Time!" : "Let's rest",
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
                "Set focus and rest Durations in MINUTES!",
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
                      focus = int.parse(value);
                    },
                    style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "focus"),
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
                      rest = int.parse(value);
                    },
                    style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "rest"),
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