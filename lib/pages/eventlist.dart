import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';
import '../models/event_model.dart';

class LatestEventsPage extends StatefulWidget {
  const LatestEventsPage({super.key});

  @override
  State<LatestEventsPage> createState() => _LatestEventsPageState();
}

class _LatestEventsPageState extends State<LatestEventsPage> {
  late Future<List<EventModel>> _eventsFuture;
  bool _isRefreshing = false;

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

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EventModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching events: $e");
      return [];
    }
  }

  /// Refreshes the events data.
  Future<void> refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.mediumImpact();

    setState(() {
      _eventsFuture = _fetchLatestEvents();
      _isRefreshing = false;
    });
  }


  /// Gets a color for an event based on proximity to current date
  Color _getEventColor(DateTime date) {
    final daysUntil = date.difference(DateTime.now()).inDays;

    if (daysUntil < 1) {
      return Colors.red.shade400; // Today or tomorrow
    } else if (daysUntil < 3) {
      return Colors.orange.shade400; // This week
    } else if (daysUntil < 7) {
      return Colors.blue.shade400; // This week
    } else {
      return Colors.green.shade400; // Further away
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      appBar: AppBar(
        title: const Text("Upcoming Events"),
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 60, child: LinearProgressIndicator()),
                  SizedBox(height: 16),
                  Text("Loading events...", style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  const Text("Couldn't load your events"),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: refreshData,
                    child: const Text("Try Again"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    "No upcoming events",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "When you add events, they'll appear here",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          final events = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              await refreshData();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: events.length + 1, // +1 for the header
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Header section
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You have ${events.length} upcoming event${events.length == 1 ? '' : 's'}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                final event = events[index - 1];
                final eventColor = _getEventColor(event.startDate);

                return OpenContainer(
                  transitionDuration: const Duration(milliseconds: 500),
                  openBuilder: (context, _) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(event.title),
                        backgroundColor: eventColor.withOpacity(0.8),
                      ),
                      body: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date and time section
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: eventColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: eventColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormat('EEEE, MMMM d, yyyy').format(event.startDate),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('h:mm a').format(event.startDate),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Location section
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Theme.of(context).colorScheme.secondary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      event.location,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Description section
                              const Text(
                                "Description",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                event.description ?? "No description provided",
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  closedElevation: 0,
                  closedShape: RoundedRectangleBorder(

                  ),
                  closedColor: Colors.transparent,
                  closedBuilder: (context, openContainer) {
                    return Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surface,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: openContainer,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Left date indicator
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: eventColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('d').format(event.startDate),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: eventColor,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('MMM').format(event.startDate),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: eventColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Event details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('h:mm a').format(event.startDate),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          event.location,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    // Preview of description
                                    if (event.description != null && event.description!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        event.description!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Category icon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onInverseSurface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.event,
                                  color: eventColor,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}