import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/userdata_model.dart'; // Import your StudentModel

class DataSendForm extends StatefulWidget {
  const DataSendForm({super.key});

  @override
  State<DataSendForm> createState() => _DataSendFormState();
}

class _DataSendFormState extends State<DataSendForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> storeData() async {
    try {
      // Create a StudentModel instance from form inputs
      final student = StudentModel(
        courseName: _courseNameController.text,
        age: int.parse(_ageController.text),
        idNumber: _idNumberController.text,
        email: _emailController.text,
      );

      // Use the model's toMap() method when storing the data in Firestore
      await FirebaseFirestore.instance
          .collection("studentdata")
          .doc(user!.uid)
          .set(student.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data sent successfully")),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Data submission failed!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.onInverseSurface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card.filled(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Enter Your Details",
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _courseNameController,
                    decoration: InputDecoration(
                      labelText: "Course Name",
                      prefixIcon: const Icon(Icons.book),
                      labelStyle: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter course name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Age",
                      prefixIcon: const Icon(Icons.cake),
                      labelStyle: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      } else if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _idNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "ID Number",
                      prefixIcon: const Icon(Icons.perm_identity),
                      labelStyle: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ID number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Student Email",
                      prefixIcon: const Icon(Icons.email),
                      labelStyle: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          storeData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                      ),
                      child: Text(
                        'Submit',
                        style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _ageController.dispose();
    _idNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
