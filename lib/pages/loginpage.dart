import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nsbm_student_academic_tracker/functions/signinfunction.dart';
import 'package:nsbm_student_academic_tracker/pages/homescreen.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> with TickerProviderStateMixin {
  bool isGoogleLoading = false;

  // Animation controller for the bubble (color and scale).
  late AnimationController _bubbleController;
  late Animation<Color?> _bubbleColorAnimation;
  late Animation<double> _bubbleScaleAnimation;

  // Controller for the welcome text animation.
  late AnimationController _textAnimationController;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textScaleAnimation;

  // Controller for the button animation.
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Bubble animations: Color and Scale.
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Welcome text animation controller.
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeIn,
      ),
    );
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _textScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Button animation controller.
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _buttonScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _buttonOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeIn,
      ),
    );

    // Start text and button animations with a delay.
    Future.delayed(const Duration(milliseconds: 200), () {
      _textAnimationController.forward();
      _buttonAnimationController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize bubble color and scale using the theme.
    final theme = Theme.of(context);
    _bubbleColorAnimation = ColorTween(
      begin: theme.colorScheme.onSurface,
      end: theme.colorScheme.primary,
    ).animate(_bubbleController);
    _bubbleScaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _bubbleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _textAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() async {
    setState(() => isGoogleLoading = true);
    try {
      // Sign out any previous Google sessions.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.onInverseSurface,
        // Wrap bottomSheet in SafeArea to avoid system UI interference and add extra bottom padding.
        bottomSheet: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: AnimatedBuilder(
              animation: _buttonAnimationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Opacity(
                    opacity: _buttonOpacityAnimation.value,
                    child: Transform.scale(
                      scale: _buttonScaleAnimation.value,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isGoogleLoading
                              ? null
                              : () {
                            HapticFeedback.heavyImpact();
                            _handleGoogleSignIn();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: isGoogleLoading
                              ? CircularProgressIndicator(
                            color: theme.colorScheme.onPrimary,
                          )
                              : Text(
                            "Sign in with Google",
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned(
              top: -90,
              left: MediaQuery.of(context).size.width / 2 - 100,
              child: AnimatedBuilder(
                animation: _bubbleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bubbleScaleAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _bubbleColorAnimation.value,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Main content with welcome text.
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Welcome text with combined fade, slide, and scale animations.
                  Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: AnimatedBuilder(
                      animation: _textAnimationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textOpacityAnimation.value,
                          child: SlideTransition(
                            position: _textSlideAnimation,
                            child: Transform.scale(
                              scale: _textScaleAnimation.value,
                              child: Center(
                                child: Text(
                                  "Welcome",
                                  style: theme.textTheme.headlineLarge?.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
