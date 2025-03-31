import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pages/eventlist.dart';
import '../models/event_model.dart';
import '../models/userdata_model.dart';

class DashboardHelper {

  static Widget buildSectionHeader(BuildContext context, String title, bool showMore, {VoidCallback? onMoreTap, Widget? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                icon,
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
              ),
            ],
          ),
          if (showMore)
            TextButton(
              onPressed: onMoreTap ?? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LatestEventsPage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                children: [
                  Text('See all', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static Widget buildEventsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(
          context,
          'Upcoming Events',
          true,
          icon: Icon(Icons.event, color: Theme.of(context).colorScheme.primary, size: 20),
        ),

        FutureBuilder<List<EventModel>>(
          future: fetchLatestEvents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      const Text("Couldn't load events"),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Refresh events
                        },
                        child: const Text("Try Again"),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        "No upcoming events",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "All your scheduled events will appear here",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            final events = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return buildEventCard(events[index], context );
              },
            );
          },
        ),
      ],
    );
  }

  static Widget buildEventCard(EventModel event, BuildContext context) {
    Color eventColor = _getEventColor(event.startDate, context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to event details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date container
              Container(
                width: 60,
                height: 70,
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: eventColor,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(event.startDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Theme.of(context).colorScheme.inverseSurface,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('h:mm a').format(event.startDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.inverseSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.inverseSurface,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.inverseSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (event.description != null && event.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.inverseSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Attend button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: eventColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: eventColor,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _getEventColor(DateTime date, BuildContext context) {
    final daysUntil = date.difference(DateTime.now()).inDays;

    if (daysUntil < 1) {
      return Colors.red.shade400; // Today or tomorrow
    } else if (daysUntil < 3) {
      return Colors.orange.shade400; // This week
    } else if (daysUntil < 7) {
      return Colors.blue.shade400; // This week
    } else {
      return Theme.of(context).colorScheme.inverseSurface; // Further away
    }
  }

  static Future<List<EventModel>> fetchLatestEvents() async {
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
          .limit(3)
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

  static Widget buildUserDataSection(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text("Please sign in to view your profile"),
        ),
      );
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("student").doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.person_off, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    "Profile data not found",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to profile setup
                    },
                    child: const Text("Complete Your Profile"),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final student = UserDataModel(
          userName: data['userName'] ?? '',
          courseName: data['courseName'] ?? '',
          age: data['age'] ?? 0,
          idNumber: data['idNumber'] ?? '',
          email: data['email'] ?? '',
          gpa: (data['gpa'] ?? 0.0).toDouble(),
        );

        const primaryColor = Color(0xFF2541B2); // Assuming this is the color based on gradient

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryColor, Color(0xFF3451C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Profile image or avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("student")
                          .doc(user.uid)
                          .collection("credentials")
                          .doc("userInfo")
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return _buildDefaultAvatar(student.userName);
                        }

                        final Map<String, dynamic>? userData = snapshot.data!.data() as Map<String, dynamic>?;
                        String? photoURL = userData?["photoURL"] as String?;
                        if (photoURL == null || photoURL.isEmpty) {
                          return _buildDefaultAvatar(student.userName);
                        }

                        return CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(photoURL),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student.idNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Academic info cards
              Row(
                children: [
                  // Course info
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Course",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            student.courseName.isEmpty
                                ? "Not specified"
                                : student.courseName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // GPA info
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Current GPA",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            student.gpa > 0
                                ? student.gpa.toStringAsFixed(2)
                                : "N/A",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Email info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 18,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        student.email.isEmpty
                            ? "No email provided"
                            : student.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildDefaultAvatar(String userName) {
    String initials = '';
    if (userName.isNotEmpty) {
      final nameParts = userName.split(' ');
      if (nameParts.isNotEmpty) {
        initials += nameParts[0][0];
        if (nameParts.length > 1) {
          initials += nameParts[1][0];
        }
      }
    }

    return Center(
      child: Text(
        initials.isNotEmpty ? initials.toUpperCase() : '?',
        style: const TextStyle(
          color: Color(0xFF2541B2),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  static Widget buildStatsSection(BuildContext context) {
    // Sample stats
    final stats = [
      {'icon': Icons.calendar_today, 'title': 'Classes', 'value': '12', 'color': Theme.of(context).colorScheme.onInverseSurface},
      {'icon': Icons.assignment_turned_in, 'title': 'Assignments', 'value': '5', 'color': Theme.of(context).colorScheme.secondary},
      {'icon': Icons.book, 'title': 'Courses', 'value': '4', 'color': Theme.of(context).colorScheme.onInverseSurface},
      {'icon': Icons.trending_up, 'title': 'Attendance', 'value': '92%', 'color': Colors.green},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: stats.map((stat) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onInverseSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (stat['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      stat['icon'] as IconData,
                      color: stat['color'] as Color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stat['value'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: stat['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat['title'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static Widget buildDashboard(BuildContext context) {
    return Container(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              buildUserDataSection(context),
              const SizedBox(height: 24),
              buildStatsSection(context),
              const SizedBox(height: 24),
              buildEventsSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}