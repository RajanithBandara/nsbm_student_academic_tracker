import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/userdata_model.dart';

class DataSendForm extends StatefulWidget {
  const DataSendForm({super.key});

  @override
  State<DataSendForm> createState() => _DataSendFormState();
}

class _DataSendFormState extends State<DataSendForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _gpaController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> storeData() async {
    try {
      final userData = UserDataModel(
        userName: _userNameController.text,
        courseName: _courseNameController.text,
        age: int.parse(_ageController.text),
        idNumber: _idNumberController.text,
        email: _emailController.text,
        gpa: double.tryParse(_gpaController.text) ?? 0.0,
      );

      await FirebaseFirestore.instance
          .collection("studentdata")
          .doc(user!.uid)
          .set(userData.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data sent successfully")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data submission failed: ${e.toString()}")),
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
                  _buildTextField("User Name", _userNameController, Icons.person),
                  _buildTextField("Course Name", _courseNameController, Icons.book),
                  _buildTextField("Age", _ageController, Icons.cake, isNumber: true),
                  _buildTextField("ID Number", _idNumberController, Icons.perm_identity),
                  _buildTextField("Email", _emailController, Icons.email, isEmail: true),
                  _buildTextField("GPA", _gpaController, Icons.grade, isNumber: true),
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (isNumber && double.tryParse(value) == null) {
            return 'Enter a valid number';
          }
          if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(value)) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _courseNameController.dispose();
    _ageController.dispose();
    _idNumberController.dispose();
    _emailController.dispose();
    _gpaController.dispose();
    super.dispose();
  }
}
