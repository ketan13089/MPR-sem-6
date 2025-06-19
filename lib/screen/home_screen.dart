import 'package:flutter/material.dart';
import 'package:silent_talk_app/screen/login_screen.dart';
import 'package:silent_talk_app/widget/image_display.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Navigate to LoginScreen after 20 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0),
                radius: 1.2,
                colors: [
                  Color.lerp(const Color(0xFFD2B48C), const Color(0xFFFFDAB9), _animationController.value)!,
                  Color.lerp(const Color(0xFFFFDAB9), const Color(0xFFFFFDD0), _animationController.value)!,
                ],
                stops: const [0.4, 1.0],
              ),
            ),
            child: Center(
              child: ImageDisplay(
                imagePath: 'assets/images/silent_talk.png',
                maxImageHeight: screenSize.height * 0.5,
              ),
            ),
          );
        },
      ),
    );
  }
}
