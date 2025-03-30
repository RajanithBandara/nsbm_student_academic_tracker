import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              _buildSectionHeader(context, 'Tasks', true),
              const SizedBox(height: 16),
              _buildTasksSection(context),
              const SizedBox(height: 24),
               _buildSectionHeader(context, 'Upcoming Events', true),
              const SizedBox(height: 16),
              _buildEventsSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool showMore) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (showMore)
          TextButton(
            onPressed: () {},
            child: const Row(
              children: [
                Text('More', style: TextStyle(fontSize: 14, color: Colors.blue)),
                Icon(Icons.chevron_right, size: 16, color: Colors.blue),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTasksSection(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
        4,
        (index) => _buildTaskCard(context, 'Marketing project at School'),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, String title) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('10 Dec 2023', style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEventsSection(BuildContext context) {
    return FutureBuilder<List<EventModel>>(
      future: _fetchLatestEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No upcoming events"));
        }
        return Column(
          children: snapshot.data!.map((event) => _buildEventCard(event)).toList(),
        );
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('MMM').format(event.startDate),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('d').format(event.startDate),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text("📍 ${event.location}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text("📅 ${DateFormat('EEEE, MMM d, yyyy').format(event.startDate)}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Future<List<EventModel>> _fetchLatestEvents() async {
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

  
}
