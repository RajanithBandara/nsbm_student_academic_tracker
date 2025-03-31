import 'dart:async';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with SingleTickerProviderStateMixin {
  TimeOfDay? targetTime;
  Duration remainingTime = Duration.zero;
  Timer? _timer;
  bool isRunning = false;
  int? _totalTimeSeconds;
  late AnimationController _animationController;
  final List<Color> _gradientColors = [
    Colors.blue.shade300,
    Colors.blue.shade500,
    Colors.indigo.shade500,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initializeNotifications();
    _checkNotificationPermission();
  }

  void _initializeNotifications() {
    AwesomeNotifications().initialize(
      'resource://drawable/res_notification_app_icon',
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Timer Notifications',
          channelDescription: 'Notifications for timer events',
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          importance: NotificationImportance.High,
          vibrationPattern: highVibrationPattern,
          soundSource: 'resource://raw/res_notification_sound',
        ),
        NotificationChannel(
          channelKey: 'timer_complete_channel',
          channelName: 'Timer Completion',
          channelDescription: 'Notifications for timer completion',
          defaultColor: Colors.green,
          ledColor: Colors.green,
          importance: NotificationImportance.Max,
          vibrationPattern: highVibrationPattern,
          soundSource: 'resource://raw/res_custom_notification_sound',
        ),
      ],
    );
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              hourMinuteTextColor: Theme.of(context).colorScheme.primary,
              dialHandColor: Theme.of(context).colorScheme.primary,
              dialBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
          ),
          child: child!,
        );
      },
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

        // Send warning notification when 5 minutes remaining
        if (remainingTime.inMinutes == 5 && remainingTime.inSeconds % 60 == 0) {
          _sendWarningNotification();
        }
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

    String statusEmoji = isRunning ? "⏱️" : (paused ? "⏸️" : "⏰");
    String timeRemaining = _formatDuration(remainingTime);

    // Use different color indicators based on remaining time
    String indicator = "";
    if (remainingTime.inMinutes <= 5) {
      indicator = "🔴";
    } else if (remainingTime.inMinutes <= 15) {
      indicator = "🟠";
    } else {
      indicator = "🟢";
    }

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        icon: 'resource://mipmap/ic_launcher',
        id: 2,
        channelKey: 'basic_channel',
        title: "$statusEmoji ${isRunning ? "Timer Running" : (paused ? "Timer Paused" : "Timer")}",
        body: "$indicator Remaining: $timeRemaining ($progressPercentage%)",
        notificationLayout: NotificationLayout.ProgressBar,
        progress: progressPercentage.toDouble(),
        locked: true,
        autoDismissible: false,
        payload: {'action': 'timer_notification'},
      ),
      actionButtons: [
        NotificationActionButton(
          key: isRunning ? 'pause' : 'resume',
          label: isRunning ? 'Pause' : 'Resume',
        ),
        NotificationActionButton(
          key: 'reset',
          label: 'Reset',
          isDangerousOption: true,
        ),
      ],
    );
  }

  void _sendWarningNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 3,
        icon: 'resource://mipmap/ic_launcher',
        channelKey: 'basic_channel',
        title: "⚠️ Almost there!",
        body: "Only 5 minutes remaining on your timer!",
        notificationLayout: NotificationLayout.Default,
        criticalAlert: false,
        wakeUpScreen: true,
      ),
    );
  }

  void _showCompletionNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        icon: 'resource://mipmap/ic_launcher',
        channelKey: 'timer_complete_channel',
        title: "⏰ Time's Up!",
        body: "Your countdown timer has ended.",
        notificationLayout: NotificationLayout.Default,
        criticalAlert: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: false,
        category: NotificationCategory.Reminder,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'dismiss',
          label: 'Dismiss',
        ),
        NotificationActionButton(
          key: 'snooze',
          label: 'Snooze 5 min',
          color: Colors.blue,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  String _getTimerDescription() {
    if (targetTime == null) return "Set a countdown timer";

    final now = TimeOfDay.now();
    final target = targetTime!;

    return "Counting down to ${target.format(context)}";
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_totalTimeSeconds != null && _totalTimeSeconds! > 0)
        ? ((1 - (remainingTime.inSeconds / _totalTimeSeconds!)).clamp(0.0, 1.0))
        : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Countdown Timer"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background.withOpacity(0.8),
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getTimerDescription(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Animated timer display
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: isRunning ? [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2 + _animationController.value * 0.2),
                                blurRadius: 20,
                                spreadRadius: 5 + _animationController.value * 5,
                              )
                            ] : null,
                          ),
                          child: child,
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background gradient circle
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.surfaceVariant,
                                  Theme.of(context).colorScheme.surface,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          // Progress indicator
                          SizedBox(
                            width: 220,
                            height: 220,
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return SweepGradient(
                                  startAngle: 0.0,
                                  endAngle: 3.14 * 2,
                                  stops: const [0.0, 0.5, 1.0],
                                  center: Alignment.center,
                                  colors: _gradientColors,
                                ).createShader(rect);
                              },
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                          // Timer display
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatDuration(remainingTime),
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              if (isRunning && targetTime != null)
                                Text(
                                  "Until ${targetTime!.format(context)}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Timer controls
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickTargetTime,
                              icon: const Icon(Icons.access_time),
                              label: const Text("Pick Target Time"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            if (remainingTime.inSeconds > 0)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: isRunning ? _pauseTimer : _startTimer,
                                      icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                                      label: Text(isRunning ? "Pause" : "Start"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isRunning
                                            ? Colors.amber
                                            : Theme.of(context).colorScheme.primary,
                                        foregroundColor: Theme.of(context).colorScheme.primary,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _resetTimer,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text("Reset"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (remainingTime.inSeconds > 0 && isRunning)
                      Text(
                        "Timer will notify you when time's up!",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
}