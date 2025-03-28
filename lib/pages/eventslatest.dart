import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nsbm_student_academic_tracker/models/event_model.dart';
import 'package:nsbm_student_academic_tracker/config/event_service.dart';
import 'package:intl/intl.dart';

class UpcomingEventsPage extends StatefulWidget {
  final String uid;

  const UpcomingEventsPage({super.key, required this.uid});

  @override
  _UpcomingEventsPageState createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  final EventService _eventService = EventService();
  late Future<List<EventModel>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _fetchUpcomingEvents();
  }

  Future<List<EventModel>> _fetchUpcomingEvents() async {
    final eventsMap = await _eventService.fetchEvents(widget.uid);
    final now = DateTime.now();
    final nextWeek = now.add(Duration(days: 7));

    List<EventModel> upcomingEvents = [];
    eventsMap.forEach((date, events) {
      if (date.isAfter(now) && date.isBefore(nextWeek)) {
        upcomingEvents.addAll(events);
      }
    });

    upcomingEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcomingEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upcoming Events")),
      body: FutureBuilder<List<EventModel>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading events"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No upcoming events"));
          }

          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📅 ${DateFormat('EEEE, MMM d, yyyy').format(event.startDate)}"),
                      Text("📍 ${event.location}"),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}