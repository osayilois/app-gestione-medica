/* import 'package:flutter/material.dart';
import 'dart:async';

/// A simple splash screen with pulsing logo animation
class SplashScreen extends StatefulWidget {
  /// Duration to display splash
  final Duration duration;

  /// Destination builder when splash is done
  final WidgetBuilder nextScreen;

  const SplashScreen({
    Key? key,
    this.duration = const Duration(seconds: 3),
    required this.nextScreen,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();

    // Animation controller for pulsing effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Scale between 0.9 and 1.1
    _scaleAnim = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_controller);

    // Color tween from white to deep purple
    _colorAnim = ColorTween(
      begin: Colors.white,
      end: Colors.deepPurple.shade300,
    ).animate(_controller);

    // After [widget.duration], navigate to next screen
    Timer(widget.duration, () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: widget.nextScreen));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade300,
      body: Center(
        // AnimatedBuilder for both scale and color
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _colorAnim.value ?? Colors.white,
                  BlendMode.srcATop,
                ),
                child: child,
              ),
            );
          },
          // Logo image as child
          child: Image.asset(
            'assets/logo.png', // place your PNG here
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}
 */

import 'package:flutter/material.dart';

/// A simple splash screen that shows a pulsing logo and then navigates on.
class SplashScreen extends StatefulWidget {
  final Duration duration;
  final Widget Function(BuildContext) nextScreen;

  const SplashScreen({
    Key? key,
    required this.duration,
    required this.nextScreen,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(widget.duration, () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: widget.nextScreen));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/medicare_logo.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
