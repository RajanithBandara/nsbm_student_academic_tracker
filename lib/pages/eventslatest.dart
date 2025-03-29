import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';

class LatestEventsPage extends StatefulWidget {
  const LatestEventsPage({super.key});

  @override
  State<LatestEventsPage> createState() => _LatestEventsPageState();
}

class _LatestEventsPageState extends State<LatestEventsPage> {
  late Future<List<EventModel>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _fetchLatestEvents();
  }

  /// Fetches the latest upcoming events for the current user.
  Future<List<EventModel>> _fetchLatestEvents() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("No user logged in.");
      return [];
    }

    try {
      DateTime now = DateTime.now();
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("student")
          .doc(user.uid)
          .collection("events")
          .where("startDate", isGreaterThanOrEqualTo: now)
          .orderBy("startDate", descending: false)
          .limit(10)
          .get();

      List<EventModel> events = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Use your EventModel factory to convert document data.
        return EventModel.fromMap(data, doc.id);
      }).toList();

      return events;
    } catch (e) {
      debugPrint("Error fetching events: $e");
      return [];
    }
  }

  /// Refreshes the events data.
  void refreshData() {
    setState(() {
      _eventsFuture = _fetchLatestEvents();
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upcoming Events"),
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading events"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No upcoming events"));
          }

          final events = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              refreshData();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📅 ${DateFormat('EEEE, MMM d, yyyy').format(event.startDate)}"),
                        Text("📍 ${event.location}"),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
