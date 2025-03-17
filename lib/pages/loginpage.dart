import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nsbm_student_academic_tracker/functions/signinfunction.dart';
import 'package:nsbm_student_academic_tracker/pages/homescreen.dart';
import 'package:nsbm_student_academic_tracker/pages/signuppage.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isSignInLoading = false;
  bool isGoogleLoading = false;
  bool isPasswordVisible = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  double _opacity = 0.0; // Initially hidden

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Slide up animation from the bottom
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Start animations after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 1.0;
      });
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() async {
    setState(() => isGoogleLoading = true);
    try {
      await GoogleSignIn().signOut();
      final userCredential = await AuthService.signInWithGoogle(context);
      if (userCredential != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (error) {
      debugPrint("Google Sign-In Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Google Sign-In failed. Please try again."),
        ),
      );
    } finally {
      setState(() => isGoogleLoading = false);
    }
  }

  void _loginUser() async {
    setState(() => isSignInLoading = true);
    final userCredential = await AuthService.signInWithEmail(
      context,
      emailController.text,
      passwordController.text,
    );
    if (userCredential != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
    setState(() => isSignInLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.onInverseSurface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 700),
              opacity: _opacity,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Login",
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Enter your email to login",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildEmailField(),
                        const SizedBox(height: 30),
                        _buildPasswordField(),
                        const SizedBox(height: 30),
                        _buildSignInButton(),
                        const SizedBox(height: 20),
                        _buildGoogleSignInButton(),
                        const SizedBox(height: 20),
                        _buildSignUpOption(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.onSurface),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildEmailField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: emailController,
      decoration: _inputDecoration("Email Address"),
      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "Please enter an email";
        if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
          return "Enter a valid email";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: passwordController,
      obscureText: !isPasswordVisible,
      decoration: _inputDecoration("Password").copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
        ),
      ),
      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
      validator: (value) {
        if (value == null || value.isEmpty) return "Please enter a password";
        if (value.length < 6) return "Password must be at least 6 characters";
        return null;
      },
    );
  }

  Widget _buildSignInButton() {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSignInLoading ? null : () {
          HapticFeedback.lightImpact();
          _loginUser();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: isSignInLoading
            ? CircularProgressIndicator(color: theme.colorScheme.onPrimary)
            : Text(
          "Sign In",
          style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isGoogleLoading ? null : () {
          _handleGoogleSignIn();
          HapticFeedback.heavyImpact();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: isGoogleLoading
            ? CircularProgressIndicator(color: theme.colorScheme.onSurface)
            : Text("Sign in with Google", style: theme.textTheme.labelLarge),
      ),
    );
  }

  Widget _buildSignUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: (){
            HapticFeedback.lightImpact();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignupPage()),
            );
          },
          child: const Text("Sign Up"),
        ),
      ],
    );
  }
}
