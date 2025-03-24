import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/userdata_model.dart'; // Ensure UserDataModel is imported

class FetchData extends StatefulWidget {
  const FetchData({super.key});

  @override
  State<FetchData> createState() => _FetchDataState();
}

class _FetchDataState extends State<FetchData> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      body: user == null
          ? _buildNoUserWidget(context)
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("studentdata")
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildNoDataWidget(context);
          }

          // Convert the Firestore document data into a UserDataModel instance.
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final student = UserDataModel(
            userName: data['userName'] ?? '',
            courseName: data['courseName'] ?? '',
            age: data['age'] ?? 0,
            idNumber: data['idNumber'] ?? '',
            email: data['email'] ?? '',
            gpa: (data['gpa'] ?? 0.0).toDouble(),
          );

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(context),
                  const SizedBox(height: 10),
                  Text(
                    student.userName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    context,
                    Icons.school,
                    "Course Name",
                    student.courseName,
                  ),
                  _buildInfoCard(
                    context,
                    Icons.cake,
                    "Age",
                    student.age.toString(),
                  ),
                  _buildInfoCard(
                    context,
                    Icons.credit_card,
                    "ID Number",
                    student.idNumber,
                  ),
                  _buildInfoCard(
                    context,
                    Icons.email,
                    "Email",
                    student.email,
                  ),
                  _buildInfoCard(
                    context,
                    Icons.star,
                    "GPA",
                    student.gpa.toStringAsFixed(2),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoUserWidget(BuildContext context) {
    return Center(
      child: Text(
        "No user logged in",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }

  Widget _buildNoDataWidget(BuildContext context) {
    return Center(
      child: Text(
        "No data found",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 50,
      backgroundColor: colorScheme.primaryContainer,
      child: Icon(
        Icons.person,
        size: 60,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      color: colorScheme.surface,
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary, size: 28),
        title: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        tileColor: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
