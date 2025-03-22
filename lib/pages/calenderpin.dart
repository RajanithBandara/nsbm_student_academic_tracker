import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nsbm_student_academic_tracker/models/event_model.dart';
import 'package:nsbm_student_academic_tracker/config/event_service.dart';

class CalenderPin extends StatefulWidget {
  const CalenderPin({super.key});

  @override
  _CalenderPinState createState() => _CalenderPinState();
}

class _CalenderPinState extends State<CalenderPin> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<EventModel>> _events = {};
  final EventService _eventService = EventService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String uid = FirebaseAuth.instance.currentUser?.uid ?? "default_uid";

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final fetchedEvents = await _eventService.fetchEvents(uid);
    setState(() {
      _events
        ..clear()
        ..addAll(fetchedEvents);
    });
  }

  void _showAddEventBottomSheet() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    DateTime startDateTime = _selectedDay != null
        ? DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      TimeOfDay.now().hour,
      TimeOfDay.now().minute,
    )
        : DateTime.now();
    DateTime endDateTime = startDateTime.add(const Duration(hours: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateSheet) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 12,
              right: 12,
              top: 12,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: "Location",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startDateTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(startDateTime),
                        );
                        if (pickedTime != null) {
                          setStateSheet(() {
                            startDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            if (endDateTime.isBefore(startDateTime)) {
                              endDateTime = startDateTime.add(const Duration(hours: 1));
                            }
                          });
                        }
                      }
                    },
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    child: Text(
                      "Select Start: ${startDateTime.toLocal().toString().split('.')[0]}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: endDateTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(endDateTime),
                        );
                        if (pickedTime != null) {
                          setStateSheet(() {
                            endDateTime = DateTime(
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
                    style:
                    ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    child: Text(
                      "Select End: ${endDateTime.toLocal().toString().split('.')[0]}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      if (titleController.text.isEmpty ||
                          descriptionController.text.isEmpty ||
                          locationController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill in all fields")),
                        );
                        return;
                      }
                      if (endDateTime.isBefore(startDateTime)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("End time must be after start time")),
                        );
                        return;
                      }
                      final newEvent = EventModel(
                        title: titleController.text,
                        description: descriptionController.text,
                        startDate: startDateTime,
                        endDate: endDateTime,
                        location: locationController.text,
                        id: '',
                      );

                      final addedEvent = await _eventService.sendEvent(uid, newEvent);
                      if (addedEvent != null) {
                        final eventDate = DateTime(
                          addedEvent.startDate.year,
                          addedEvent.startDate.month,
                          addedEvent.startDate.day,
                        );
                        setState(() {
                          _events.putIfAbsent(eventDate, () => []);
                          _events[eventDate]!.add(addedEvent);
                        });
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text("Add Event", style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),),
                  ),
                  SizedBox(height: 26,)
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _deleteEvent(EventModel event) async {
    try {
      await _firestore
          .collection('studentdata')
          .doc(uid)
          .collection('events')
          .doc(event.id)
          .delete();
      final eventDate = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );
      setState(() {
        _events[eventDate]?.removeWhere((e) => e.id == event.id);
      });
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      body: Column(
        children: [
          Card(
            elevation: 2,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              eventLoader: (day) =>
              _events[DateTime(day.year, day.month, day.day)] ?? [],
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Event List
          Expanded(
            child: _selectedDay != null &&
                (_events[DateTime(
                  _selectedDay!.year,
                  _selectedDay!.month,
                  _selectedDay!.day,
                )]
                    ?.isNotEmpty ??
                    false)
                ? ListView(
              children: (_events[DateTime(
                _selectedDay!.year,
                _selectedDay!.month,
                _selectedDay!.day,
              )] ??
                  [])
                  .map((event) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      event.title,
                      style:
                      TextStyle(color: colorScheme.onSurface),
                    ),
                    subtitle: Text(
                      "From: ${event.startDate.toLocal().toString().split('.')[0]}\nTo: ${event.endDate.toLocal().toString().split('.')[0]}",
                      style:
                      Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteEvent(event);
                        HapticFeedback.mediumImpact();
                      }
                    ),
                  ),
                );
              }).toList(),
            )
                : Center(
              child: Text(
                "No events for this day",
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventBottomSheet,
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
