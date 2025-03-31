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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedEvents = await _eventService.fetchEvents(uid);
      setState(() {
        _events.clear();
        _events.addAll(fetchedEvents);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading events: $e")),
        );
      }
    }
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateSheet) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add New Event",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Description",
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: "Location",
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date time selectors with better styles
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          label: Text(
                            "Start: ${_formatDateTime(startDateTime)}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.event_available),
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: endDateTime,
                              firstDate: startDateTime,
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          label: Text(
                            "End: ${_formatDateTime(endDateTime)}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Submit button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
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

                            // Show loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(child: CircularProgressIndicator()),
                            );

                            try {
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
                                  if (!_events.containsKey(eventDate)) {
                                    _events[eventDate] = [];
                                  }
                                  _events[eventDate]!.add(addedEvent);
                                });

                                // Close loading dialog and bottom sheet
                                Navigator.pop(context); // Close loading dialog
                                Navigator.pop(context); // Close bottom sheet

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Event added successfully"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              // Close loading dialog
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error adding event: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Add Event",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _deleteEvent(EventModel event) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Event"),
        content: Text("Are you sure you want to delete '${event.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmDelete) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _firestore
          .collection('student')
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
        if (_events.containsKey(eventDate)) {
          _events[eventDate]!.removeWhere((e) => e.id == event.id);
          // If the list is empty after removal, remove the key
          if (_events[eventDate]!.isEmpty) {
            _events.remove(eventDate);
          }
        }
      });

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Event deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting event: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
            tooltip: "Refresh Events",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Card(
            elevation: 4,
            margin: const EdgeInsets.all(12),
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
                HapticFeedback.lightImpact();
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return _events[normalizedDay] ?? [];
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                formatButtonTextStyle: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: colorScheme.onSurface,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface,
                ),
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
                markersMaxCount: 3,
                outsideDaysVisible: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDay != null
                      ? "Events for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}"
                      : "Events",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _selectedDay != null &&
                      (_events[DateTime(
                        _selectedDay!.year,
                        _selectedDay!.month,
                        _selectedDay!.day,
                      )]
                          ?.isNotEmpty ??
                          false)
                      ? "${_events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]?.length} events"
                      : "No events",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
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
                ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: (_events[DateTime(
                _selectedDay!.year,
                _selectedDay!.month,
                _selectedDay!.day,
              )] ??
                  [])
                  .length,
              itemBuilder: (context, index) {
                final event = (_events[DateTime(
                  _selectedDay!.year,
                  _selectedDay!.month,
                  _selectedDay!.day,
                )] ??
                    [])[index];

                return Dismissible(
                  key: Key(event.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Event"),
                        content: Text("Are you sure you want to delete '${event.title}'?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (direction) {
                    _deleteEvent(event);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        event.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${event.startDate.hour}:${event.startDate.minute.toString().padLeft(2, '0')} - ${event.endDate.hour}:${event.endDate.minute.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                event.location,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteEvent(event);
                          HapticFeedback.mediumImpact();
                        },
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              Text(
                                "Description:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.description,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Time Details:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "From: ${event.startDate.toLocal().toString().split('.')[0]}",
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                "To: ${event.endDate.toLocal().toString().split('.')[0]}",
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No events for this day",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventBottomSheet,
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white,),
        label: const Text("Add Event", style: TextStyle(color: Colors.white),),
      ),
    );
  }
}