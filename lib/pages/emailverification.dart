import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailVerificationScreen extends StatefulWidget {
  final User user;
  const EmailVerificationScreen({super.key, required this.user});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => checkEmailVerified());
  }

  Future<void> checkEmailVerified() async {
    await widget.user.reload();
    setState(() {
      isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isVerified) {
      timer?.cancel(); // Stop checking once verified
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Email verified! Account activated.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      await FirebaseFirestore.instance.collection("users").doc(widget.user.uid).set({
        "uid": widget.user.uid,
        "email": widget.user.email,
        "createdAt": FieldValue.serverTimestamp(),
        "verified": true,
      });

      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "A verification email has been sent.\nPlease verify your email before proceeding.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkEmailVerified,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              ),
              child: Text(
                  "I have verified my email",
                  style: TextStyle(
                    color: Colors.white,
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
