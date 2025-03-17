import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nsbm_student_academic_tracker/functions/signinfunction.dart';
import 'package:nsbm_student_academic_tracker/functions/signupfunction.dart';
import 'package:nsbm_student_academic_tracker/pages/emailverification.dart';
import 'package:nsbm_student_academic_tracker/pages/homescreen.dart';
import 'package:nsbm_student_academic_tracker/pages/loginpage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSigningUp = false;
  bool _isGoogleSigning = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _createUserWithPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSigningUp = true);
    try {
      final user = await AuthServiceSignup.createUserWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null) {
        await FirebaseFirestore.instance.collection('students').doc(user.uid).set({
          'displayName': _fullNameController.text.trim(),
          'email': user.email,
        }, SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User created successfully! Verification email sent.")),
        );
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmailVerificationScreen(user: user)),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup failed!")),
      );
    } finally {
      setState(() => _isSigningUp = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isGoogleSigning = true);
    try {
      final user = await AuthServiceSignup.signInWithGoogle();
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign-In Successful!")),
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed: $e")),
      );
    } finally {
      setState(() => _isGoogleSigning = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary)),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.outline)),
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Sign Up", style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Create an account to get started", style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
                      const SizedBox(height: 30),
                      TextFormField(
                          controller: _fullNameController,
                          decoration: _inputDecoration("Full Name"),
                          validator: (value) => (value == null || value.isEmpty) ? "Enter your full name" : null),
                      const SizedBox(height: 20),
                      TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration("Email"),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => (value == null || value.isEmpty) ? "Enter a valid email" : null),
                      const SizedBox(height: 20),
                      TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: _inputDecoration("Password"),
                          validator: (value) => (value == null || value.length < 6) ? "Password must be at least 6 characters" : null),
                      const SizedBox(height: 30),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: _isSigningUp ? null : _createUserWithPassword,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14)),
                              child: _isSigningUp ? CircularProgressIndicator(
                                  color: theme.colorScheme.onPrimary) : Text(
                                  "Sign Up", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)))),
                      const SizedBox(height: 10),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: (){
                                HapticFeedback.heavyImpact();
                              _isGoogleSigning ? null : _signUpWithGoogle;
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.surface,
                                  padding: const EdgeInsets.symmetric(vertical: 14)),
                              child: _isGoogleSigning ? CircularProgressIndicator(
                                  color: theme.colorScheme.onSurface
                              ) : Text(
                                  "Sign Up with Google",
                                  style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.onSurface
                                  )))),
                      const SizedBox( height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account? ", style: theme.textTheme.bodyMedium),
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Signin()),
                              );
                            },
                            child: Text(
                                "Sign In",
                                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                          ),
                          ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}