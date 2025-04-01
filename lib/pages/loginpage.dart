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

  // Animation controller for the bubble (color and scale)
  late AnimationController _bubbleController;
  late Animation<Color?> _bubbleColorAnimation;
  late Animation<double> _bubbleScaleAnimation;

  // Secondary bubble animations
  late AnimationController _secondaryBubbleController;
  late Animation<double> _secondaryBubbleScale;

  // Controller for the welcome text animation
  late AnimationController _textAnimationController;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textScaleAnimation;

  // Subtitle text animation
  late Animation<double> _subtitleOpacityAnimation;
  late Animation<Offset> _subtitleSlideAnimation;

  // Controller for the button animation
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonOpacityAnimation;

  // Logo animation
  late AnimationController _logoAnimationController;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Primary bubble animations
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Secondary bubble animations
    _secondaryBubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _secondaryBubbleScale = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(
        parent: _secondaryBubbleController,
        curve: Curves.easeInOut,
      ),
    );

    // Text animation controllers
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

    // Subtitle animations
    _subtitleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Button animation controller
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

    // Logo animation controller
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations with staggered timing
    Future.delayed(const Duration(milliseconds: 100), () {
      _textAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _logoAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _buttonAnimationController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize bubble color animation with theme colors
    final theme = Theme.of(context);
    _bubbleColorAnimation = ColorTween(
      begin: theme.colorScheme.primary.withOpacity(0.7),
      end: theme.colorScheme.secondary.withOpacity(0.7),
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
    _secondaryBubbleController.dispose();
    _textAnimationController.dispose();
    _buttonAnimationController.dispose();
    _logoAnimationController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() async {
    setState(() => isGoogleLoading = true);
    try {
      // Sign out any previous Google sessions
      await GoogleSignIn().signOut();
      final userCredential = await AuthService.signInWithGoogle(context);
      if (userCredential != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreenUi()),
        );
      }
    } catch (error) {
      debugPrint("Google Sign-In Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Sign-In failed. Please try again."),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        // Enhanced bottom sheet for sign-in button
        bottomSheet: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: AnimatedBuilder(
              animation: _buttonAnimationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _buttonOpacityAnimation.value,
                  child: Transform.scale(
                    scale: _buttonScaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Get Started",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Track your academic progress and stay on top of your education journey",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: isGoogleLoading
                                ? null
                                : () {
                              HapticFeedback.mediumImpact();
                              _handleGoogleSignIn();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            icon: isGoogleLoading
                                ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.onPrimary,
                                strokeWidth: 3,
                              ),
                            )
                                : Image.asset(
                              'lib/assets/google_logo.png',
                              width: 24,
                              height: 24,
                            ),
                            label: Text(
                              "Sign in with Google",
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        body: Stack(
          children: [
            // Background decorative elements
            // Primary animated bubble
            Positioned(
              top: -screenSize.width * 0.1,
              right: -screenSize.width * 0.15,
              child: AnimatedBuilder(
                animation: _bubbleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bubbleScaleAnimation.value,
                    child: Container(
                      width: screenSize.width * 0.6,
                      height: screenSize.width * 0.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _bubbleColorAnimation.value,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Secondary animated bubble
            Positioned(
              left: -screenSize.width * 0.2,
              bottom: screenSize.height * 0.3,
              child: AnimatedBuilder(
                animation: _secondaryBubbleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _secondaryBubbleScale.value,
                    child: Container(
                      width: screenSize.width * 0.5,
                      height: screenSize.width * 0.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.tertiary.withOpacity(0.5),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main content with layout improvements for better centering
            SafeArea(
              child: Column(
                children: [
                  // Content in the top section (titles)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 72, 24, 0),
                    child: Column(
                      children: [
                        // Animated welcome text
                        AnimatedBuilder(
                          animation: _textAnimationController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _textOpacityAnimation.value,
                              child: SlideTransition(
                                position: _textSlideAnimation,
                                child: Transform.scale(
                                  scale: _textScaleAnimation.value,
                                  child: Text(
                                    "Welcome to EduTrack",
                                    style: theme.textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onBackground,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Animated subtitle
                        AnimatedBuilder(
                          animation: _textAnimationController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _subtitleOpacityAnimation.value,
                              child: SlideTransition(
                                position: _subtitleSlideAnimation,
                                child: Text(
                                  "Your personal academic companion",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onBackground.withOpacity(0.8),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Centered logo section with flexible spacing
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // This container ensures the image is placed at the center of the screen
                        Container(
                          alignment: Alignment.center,
                          child: AnimatedBuilder(
                            animation: _logoAnimationController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _logoOpacityAnimation.value,
                                child: Transform.scale(
                                  scale: _logoScaleAnimation.value,
                                  child: Image.asset(
                                    'lib/assets/EduTrack.png',
                                    width: screenSize.width * 0.7,
                                    // Center the image both horizontally and vertically
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Added bottom padding to balance the layout
                  SizedBox(height: screenSize.height * 0.35),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}