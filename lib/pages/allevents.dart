import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';

class AllEvents extends StatelessWidget {
  const AllEvents({super.key});

  Future<List<EventModel>> fetchAllUpcomingEvents() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      DateTime now = DateTime.now();
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("student")
          .doc(user.uid)
          .collection("events")
          .where("startDate", isGreaterThanOrEqualTo: now)
          .orderBy("startDate", descending: false)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
      ),
      body: FutureBuilder<List<EventModel>>(
        future: fetchAllUpcomingEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No upcoming events", style: TextStyle(fontSize: 16)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              EventModel event = snapshot.data![index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('MMM').format(event.startDate).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('d').format(event.startDate),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    event.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📍 ${event.location}", style: const TextStyle(fontSize: 14)),
                      Text("📅 ${DateFormat('EEEE, MMM d, yyyy').format(event.startDate)}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    // Navigate to event details if needed
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
