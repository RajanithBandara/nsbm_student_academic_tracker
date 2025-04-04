import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nsbm_student_academic_tracker/pages/welcomescreen_2.dart';
import 'dart:math';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _floatingController;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _buttonOpacity;
  late final Animation<Offset> _buttonSlide;
  late final Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation sequence controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Controller for floating animation
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Floating animation
    _floatingAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Curves.easeInOut,
      ),
    );

    // Logo animations
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    // Title animations
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeIn),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOut),
      ),
    );

    // Subtitle animation
    _subtitleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.7, curve: Curves.easeIn),
      ),
    );

    // Button animations
    _buttonOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.9, curve: Curves.easeIn),
      ),
    );

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.9, curve: Curves.easeOut),
      ),
    );

    // Start the main animation sequence
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Material color scheme
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    );

    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: colorScheme.background,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: MaterialBackgroundPainter(colorScheme),
              ),
            ),

            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FadeTransition(
                          opacity: _logoOpacity,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: AnimatedBuilder(
                              animation: _floatingAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _floatingAnimation.value),
                                  child: Container(
                                    padding: const EdgeInsets.all(11),
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.shadow.withOpacity(0.2),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'lib/assets/logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Title
                        SlideTransition(
                          position: _titleSlide,
                          child: FadeTransition(
                            opacity: _titleOpacity,
                            child: Column(
                              children: [
                                Text(
                                  "WELCOME TO",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "EduTrack",
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: colorScheme.onBackground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Subtitle
                        FadeTransition(
                          opacity: _subtitleOpacity,
                          child: Card(
                            elevation: 0,
                            color: colorScheme.surfaceVariant,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Text(
                                "Your complete academic companion",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 64),

                        // Button
                        SlideTransition(
                          position: _buttonSlide,
                          child: FadeTransition(
                            opacity: _buttonOpacity,
                            child: FilledButton.tonal(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                    const WelcomeDetailsScreen(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.1),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.primaryContainer,
                                foregroundColor: colorScheme.primary,
                                minimumSize: const Size(200, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Get Started",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for Material Design shape patterns in the background
class MaterialBackgroundPainter extends CustomPainter {
  final ColorScheme colorScheme;

  MaterialBackgroundPainter(this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(42);

    // Draw various Material Design shapes

    // Large circle in top right
    Paint circlePaint = Paint()
      ..color = colorScheme.primaryContainer.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width + 50, -50),
      size.width * 0.4,
      circlePaint,
    );

    // Soft rectangle in bottom left
    Paint rectPaint = Paint()
      ..color = colorScheme.secondaryContainer.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final RRect roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-40, size.height - 150, size.width * 0.5, 300),
      Radius.circular(60),
    );

    canvas.drawRRect(roundedRect, rectPaint);

    // Small circles/dots pattern
    final dotPaint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 8 + 2;

      // Alternating tertiary and secondary colors
      if (i % 2 == 0) {
        dotPaint.color = colorScheme.tertiary.withOpacity(0.1);
      } else {
        dotPaint.color = colorScheme.secondary.withOpacity(0.1);
      }

      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }

    // Additional squircle shape
    final squirclePaint = Paint()
      ..color = colorScheme.tertiaryContainer.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final squircleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.4, size.width * 0.5, size.width * 0.5),
      Radius.circular(40),
    );

    canvas.drawRRect(squircleRect, squirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}