import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nsbm_student_academic_tracker/functions/signinfunction.dart';
import 'package:nsbm_student_academic_tracker/functions/signupfunction.dart';
import 'package:nsbm_student_academic_tracker/pages/emailverification.dart';
import 'package:nsbm_student_academic_tracker/pages/homescreen.dart';
import 'package:nsbm_student_academic_tracker/pages/loginpage.dart'; // <-- Import your AuthService

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController(); // For full name field

  final _formKey = GlobalKey<FormState>();

  bool _isSigningUp = false;
  bool _isGoogleSigning = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  // Create user with email/password using AuthService
  Future<void> _createUserWithPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSigningUp = true);

    try {
      final user = await AuthServiceSignup.createUserWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Optionally store the user's full name in Firestore as well
        // If you'd like to store fullName upon sign-up:
        await FirebaseFirestore.instance.collection('students').doc(user.uid).set({
          'displayName': _fullNameController.text.trim(),
          'email': user.email,
        }, SetOptions(merge: true));

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User created successfully! Verification email sent."),
          ),
        );

        // Navigate to verification screen
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(user: user),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Show user-friendly error messages
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup failed!")),
      );
    } finally {
      setState(() => _isSigningUp = false);
    }
  }

  // Sign up with Google using AuthService
  Future<void> _signUpWithGoogle() async {
    setState(() => _isGoogleSigning = true);

    try {
      final user = await AuthServiceSignup.signInWithGoogle();
      if (user != null) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign-In Successful!")),
        );
        // Navigate to Home
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      // If AuthService throws, catch the error here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed: $e")),
      );
    } finally {
      setState(() => _isGoogleSigning = false);
    }
  }

  // Helper method to return input decoration using theme colors.
  InputDecoration _inputDecoration(String label) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle:
      theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.outline),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.onInverseSurface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sign Up",
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Create an account to get started",
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  // Full Name Field
                  TextFormField(
                    controller: _fullNameController,
                    decoration: _inputDecoration("Full Name"),
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.onSurface),
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Enter your full name"
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration("Email"),
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.onSurface),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Enter a valid email"
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration("Password"),
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.onSurface),
                    validator: (value) =>
                    (value == null || value.length < 6)
                        ? "Password must be at least 6 characters"
                        : null,
                  ),
                  const SizedBox(height: 30),

                  // Sign Up with Email/Password Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSigningUp ? null : (){
                        _createUserWithPassword();
                        HapticFeedback.heavyImpact();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isSigningUp
                          ? CircularProgressIndicator(
                        color: theme.colorScheme.onPrimary,
                      )
                          : Text(
                        "Sign Up",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Sign Up with Google Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isGoogleSigning ? null : (){
                        _signUpWithGoogle();
                        HapticFeedback.heavyImpact();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isGoogleSigning
                          ? CircularProgressIndicator(
                        color: theme.colorScheme.onSurface,
                      )
                          : Text(
                        "Sign Up with Google",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Already have an account? -> Sign in
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Signin()),
                          );
                        },
                        child: Text(
                          "Login",
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
