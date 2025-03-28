import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'todo.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  late Future<Box<Todo>> _todoBoxFuture;

  // Retrieves the current user's ID
  String? getUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // Opens a Hive box for the current user's todo items.
  Future<Box<Todo>> openUserTodoBox() async {
    final userId = getUserId();
    if (userId == null) {
      throw Exception("User not logged in");
    }
    return await Hive.openBox<Todo>('todoBox_$userId');
  }

  @override
  void initState() {
    super.initState();
    _todoBoxFuture = openUserTodoBox();
    _checkNotificationPermission();
  }

  /// Checks and requests notification permission using Awesome Notifications.
  void _checkNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Show a dialog prompting the user for notification permissions.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          title: const Text("Allow Notifications"),
          content: const Text(
              "Our app would like to send you notifications to remind you of upcoming tasks."),
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

  /// Displays a bottom sheet dialog to add a new task.
  void _addTodoDialog(Box<Todo> todoBox) {
    final TextEditingController taskController = TextEditingController();
    DateTime? selectedDateTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          title: const Text("Add Task"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Task title input
                  TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      labelText: "Task",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Button to select due date & time
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setStateDialog(() {
                            selectedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    child: const Text(
                      "Select Due Date & Time",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selectedDateTime != null)
                    Text(
                      "Selected: ${selectedDateTime!.toLocal().toString().split('.')[0]}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              );
            },
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            // Add Task button with notification push
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                if (taskController.text.isNotEmpty && selectedDateTime != null) {
                  if (selectedDateTime!.isBefore(DateTime.now())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a future date and time.")),
                    );
                    return;
                  }
                  // Create and add task to Hive
                  final todo = Todo(task: taskController.text, dateTime: selectedDateTime!);
                  final int newKey = await todoBox.add(todo);
                  // Schedule a push notification for the new task
                  await _scheduleNotification(newKey, todo);
                  // Send immediate notification confirming the task is added.
                  await _sendTaskAddedNotification(newKey, todo);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Add Task",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _scheduleNotification(int key, Todo todo) async {
    // Determine reminder time: 5 minutes before the due date (or at due date if in the past)
    DateTime reminderTime = todo.dateTime.subtract(const Duration(minutes: 5));
    if (reminderTime.isBefore(DateTime.now())) {
      reminderTime = todo.dateTime;
    }
    debugPrint('Scheduling reminder for task "${todo.task}" at $reminderTime');

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          icon: 'resource://mipmap/ic_launcher',
          id: key, // Using key as unique identifier
          channelKey: 'basic_channel',
          title: 'Task Reminder',
          body: 'Task "${todo.task}" is due soon!',
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          year: reminderTime.year,
          month: reminderTime.month,
          day: reminderTime.day,
          hour: reminderTime.hour,
          minute: reminderTime.minute,
          second: reminderTime.second,
          millisecond: 0,
          repeats: false,
        ),
      );
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  /// Sends an immediate push notification indicating that the task was added.
  Future<void> _sendTaskAddedNotification(int key, Todo todo) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          icon: 'resource://mipmap/ic_launcher',
          id: key + 10000,
          channelKey: 'basic_channel',
          title: 'Task Added',
          body: 'Task "${todo.task}" has been added!',
          notificationLayout: NotificationLayout.Default,
        ),
      );
    } catch (e) {
      debugPrint("Error sending immediate notification: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      body: FutureBuilder<Box<Todo>>(
        future: _todoBoxFuture,
        builder: (context, snapshot) {
          // Wrap content in AnimatedSwitcher for smooth transitions.
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildContent(snapshot),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _todoBoxFuture.then((box) => _addTodoDialog(box));
          HapticFeedback.lightImpact();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Builds the main content based on the state of the Hive box.
  Widget _buildContent(AsyncSnapshot<Box<Todo>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError || !snapshot.hasData) {
      return Center(child: Text("Error loading tasks: ${snapshot.error}"));
    }

    final todoBox = snapshot.data!;
    return ValueListenableBuilder(
      valueListenable: todoBox.listenable(),
      builder: (context, Box<Todo> box, _) {
        List<Todo> tasks = box.values.toList().cast<Todo>();
        tasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));

        if (tasks.isEmpty) {
          return Center(
            child: Text(
              "No Tasks Added",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          );
        }

        return ListView.builder(
          key: ValueKey(tasks.length),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final todo = tasks[index];
            final int taskKey = box.keyAt(index);
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    todo.task,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: todo.dateTime.isBefore(DateTime.now())
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    "Due: ${todo.dateTime.toLocal().toString().split('.')[0]}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      AwesomeNotifications().cancel(taskKey);
                      box.delete(taskKey);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
