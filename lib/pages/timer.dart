import 'dart:async';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  TimeOfDay? targetTime;
  Duration remainingTime = Duration.zero;
  Timer? _timer;
  bool isRunning = false;
  int? _totalTimeSeconds;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  void _checkNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Allow Notifications"),
          content: const Text("This app needs permission to send reminders."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Don't Allow"),
            ),
            TextButton(
              onPressed: () {
                AwesomeNotifications().requestPermissionToSendNotifications();
                Navigator.pop(context);
              },
              child: const Text("Allow"),
            ),
          ],
        ),
      );
    }
  }

  void _pickTargetTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        targetTime = pickedTime;
        _calculateRemainingTime();
      });
    }
  }

  void _calculateRemainingTime() {
    if (targetTime == null) return;

    DateTime now = DateTime.now();
    DateTime targetDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      targetTime!.hour,
      targetTime!.minute,
    );

    if (targetDateTime.isBefore(now)) {
      targetDateTime = targetDateTime.add(const Duration(days: 1));
    }

    _totalTimeSeconds = targetDateTime.difference(now).inSeconds;

    setState(() {
      remainingTime = Duration(seconds: _totalTimeSeconds!);
    });

    if (remainingTime.inSeconds > 0) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = true;
    });

    _updateProgressNotification();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime -= const Duration(seconds: 1);
        });
        _updateProgressNotification();
      } else {
        timer.cancel();
        setState(() {
          isRunning = false;
        });
        _showCompletionNotification();
        AwesomeNotifications().cancel(2);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
    _updateProgressNotification(paused: true);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      remainingTime = Duration.zero;
      isRunning = false;
      targetTime = null;
      _totalTimeSeconds = null;
    });
    AwesomeNotifications().cancel(2);
  }

  void _updateProgressNotification({bool paused = false}) {
    if (_totalTimeSeconds == null || _totalTimeSeconds == 0) return;
    int elapsed = _totalTimeSeconds! - remainingTime.inSeconds;
    int progressPercentage = ((_totalTimeSeconds! > 0)
        ? ((elapsed * 100) / _totalTimeSeconds!).round()
        : 0);

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'basic_channel',
        title: isRunning ? "Timer Running" : (paused ? "Timer Paused" : "Timer"),
        body: "Remaining: ${_formatDuration(remainingTime)} ($progressPercentage%)",
        notificationLayout: NotificationLayout.ProgressBar,
        progress: progressPercentage.toDouble(),
        locked: true,
        autoDismissible: false,
      ),
    );
  }

  void _showCompletionNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: "⏰ Time's Up!",
        body: "Your countdown timer has ended.",
        notificationLayout: NotificationLayout.Default,
        criticalAlert: true,
        wakeUpScreen: true,
        autoDismissible: false,
        category: NotificationCategory.Reminder,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_totalTimeSeconds != null && _totalTimeSeconds! > 0)
        ? ((1 - (remainingTime.inSeconds / _totalTimeSeconds!)).clamp(0.0, 1.0))
        : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Countdown Timer",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Text(
                  _formatDuration(remainingTime),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _pickTargetTime,
              icon: const Icon(Icons.access_time),
              label: const Text("Pick Target Time"),
            ),
            const SizedBox(height: 20),
            if (remainingTime.inSeconds > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isRunning ? _pauseTimer : _startTimer,
                    child: Text(isRunning ? "Pause" : "Start"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _resetTimer,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Reset"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
