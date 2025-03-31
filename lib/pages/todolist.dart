import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';

import 'todo.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with SingleTickerProviderStateMixin {
  late Future<Box<Todo>> _todoBoxFuture;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Checks and requests notification permission using Awesome Notifications.
  void _checkNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Show a dialog prompting the user for notification permissions.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Allow Notifications",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          content: const Text(
              "Our app would like to send you notifications to remind you of upcoming tasks."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Don't Allow",
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "New Task",
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Task title input with enhanced styling
                    TextField(
                      controller: taskController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: "What needs to be done?",
                        hintText: "Enter your task",
                        prefixIcon: const Icon(Icons.task_alt),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Date & Time selector
                    InkWell(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).colorScheme.primary,
                                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedDateTime == null
                                    ? "Select Due Date & Time"
                                    : "Due: ${DateFormat('MMM dd, yyyy - HH:mm').format(selectedDateTime!)}",
                                style: TextStyle(
                                  color: selectedDateTime == null
                                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (selectedDateTime != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setStateDialog(() {
                                    selectedDateTime = null;
                                  });
                                },
                                color: Theme.of(context).colorScheme.error,
                                iconSize: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Add Task button with improved styling
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.surface,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (taskController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please enter a task description")),
                            );
                            return;
                          }

                          if (selectedDateTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select a date and time")),
                            );
                            return;
                          }

                          if (selectedDateTime!.isBefore(DateTime.now())) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select a future date and time")),
                            );
                            return;
                          }

                          // Create and add task to Hive
                          final todo = Todo(task: taskController.text, dateTime: selectedDateTime!);
                          final int newKey = await todoBox.add(todo);

                          // Schedule notifications
                          await _scheduleNotification(newKey, todo);
                          await _sendTaskAddedNotification(newKey, todo);

                          // Add haptic feedback
                          HapticFeedback.mediumImpact();

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_task, color: Colors.white,),
                            const SizedBox(width: 8),
                            const Text(
                              "Add Task",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _scheduleNotification(int key, Todo todo) async {
    // Determine reminder time: 30 minutes before the due date (or at due date if in the past)
    DateTime reminderTime = todo.dateTime.subtract(const Duration(minutes: 30));
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
          color: Colors.blue,
          category: NotificationCategory.Reminder,
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
          preciseAlarm: true,
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
          body: 'Task "${todo.task}" has been added to your list!',
          notificationLayout: NotificationLayout.Default,
          color: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Error sending immediate notification: $e");
    }
  }

  // Get priority color based on due date
  Color _getPriorityColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inHours;

    if (dueDate.isBefore(now)) {
      return Colors.red.shade300; // Overdue
    } else if (difference <= 24) {
      return Colors.orange.shade300; // Due within 24 hours
    } else if (difference <= 72) {
      return Colors.amber.shade200; // Due within 3 days
    } else {
      return Colors.green.shade200; // Due later
    }
  }

  // Format the date in a user-friendly way
  String _formatDueDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dueDate == today) {
      return "Today at ${DateFormat('HH:mm').format(dateTime)}";
    } else if (dueDate == tomorrow) {
      return "Tomorrow at ${DateFormat('HH:mm').format(dateTime)}";
    } else {
      return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      body: FutureBuilder<Box<Todo>>(
        future: _todoBoxFuture,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildContent(snapshot),
          );
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: FloatingActionButton.extended(
              onPressed: () {
                _todoBoxFuture.then((box) => _addTodoDialog(box));
                HapticFeedback.lightImpact();
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 4,
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: const Text(
                "New Task",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Builds the main content based on the state of the Hive box.
  Widget _buildContent(AsyncSnapshot<Box<Todo>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "Loading your tasks...",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (snapshot.hasError || !snapshot.hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              "Error loading tasks",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "${snapshot.error}",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _todoBoxFuture = openUserTodoBox();
                });
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final todoBox = snapshot.data!;
    return ValueListenableBuilder(
      valueListenable: todoBox.listenable(),
      builder: (context, Box<Todo> box, _) {
        List<Todo> tasks = box.values.toList().cast<Todo>();
        tasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));

        if (tasks.isEmpty) {
          return FadeTransition(
            opacity: _animation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No Tasks Yet",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the + button to add your first task",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 80), // Space for FAB
          child: ListView.builder(
            key: ValueKey(tasks.length),
            itemCount: tasks.length,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemBuilder: (context, index) {
              final todo = tasks[index];
              final int taskKey = box.keyAt(index);
              final bool isOverdue = todo.dateTime.isBefore(DateTime.now());
              final priorityColor = _getPriorityColor(todo.dateTime);

              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuint,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Dismissible(
                  key: Key(taskKey.toString()),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  secondaryBackground: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  onDismissed: (direction) {
                    AwesomeNotifications().cancel(taskKey);
                    box.delete(taskKey);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            direction == DismissDirection.startToEnd
                                ? "Task completed"
                                : "Task deleted"
                        ),
                        action: SnackBarAction(
                          label: "Undo",
                          onPressed: () {
                            // Re-add the todo
                            box.put(taskKey, todo);
                            _scheduleNotification(taskKey, todo);
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Material(
                        color: Theme.of(context).colorScheme.surface,
                        child: InkWell(
                          onTap: () {
                            // Show task details or edit dialog
                            HapticFeedback.selectionClick();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: priorityColor,
                                  width: 6,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        todo.task,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          decoration: isOverdue
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: isOverdue
                                              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                              : Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Theme.of(context).colorScheme.error,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        HapticFeedback.mediumImpact();
                                        AwesomeNotifications().cancel(taskKey);
                                        box.delete(taskKey);

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text("Task deleted"),
                                            action: SnackBarAction(
                                              label: "Undo",
                                              onPressed: () {
                                                // Re-add the todo
                                                box.put(taskKey, todo);
                                                _scheduleNotification(taskKey, todo);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      isOverdue ? Icons.timer_off : Icons.timer,
                                      size: 16,
                                      color: isOverdue
                                          ? Colors.red
                                          : Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDueDate(todo.dateTime),
                                      style: TextStyle(
                                        color: isOverdue
                                            ? Colors.red
                                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (isOverdue) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          "OVERDUE",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}