import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'home_page.dart'; // Make sure this path is correct

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLogin = true;
  bool _showSuccessMessage = false;
  String _successMessage = '';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _submitForm() {
    setState(() {
      _successMessage = _isLogin 
          ? 'Successfully logged in!' 
          : 'Account created successfully!';
      _showSuccessMessage = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSuccessMessage = false;
        });

        // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFFFFCC80), const Color(0xFFFFD8A8), _animationController.value)!,
                      Color.lerp(const Color(0xFFFFF8E1), const Color(0xFFFFF3D0), _animationController.value)!,
                      Color.lerp(const Color(0xFFEFDBC5), const Color(0xFFE6D2B5), _animationController.value)!,
                    ],
                  ),
                ),
              );
            },
          ),

          HandGesturesAnimation(animationController: _animationController),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white.withAlpha(217),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLogin ? 'Welcome Back' : 'Create Account',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (!_isLogin)
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        if (!_isLogin) const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.email),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEFDBC5),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            _isLogin ? 'Login' : 'Sign Up',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: _toggleAuthMode,
                          child: Text(
                            _isLogin
                                ? 'Don\'t have an account? Sign Up'
                                : 'Already have an account? Login',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_showSuccessMessage)
            Positioned(
              bottom: 50,
              left: 24,
              right: 24,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(180),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withAlpha(77),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _successMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HandGesturesAnimation extends StatelessWidget {
  final AnimationController animationController;

  const HandGesturesAnimation({
    Key? key,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final List<String> handEmojis = [
      '👋', '✌️', '👍', '👏', '🤝', '🙌', '👐', '🤲', '✋', '🤚', '🖐️', '👌',
      '🤞', '🤟', '🤙', '👆', '👇', '👉', '👈', '✍️', '💪', '🫶', '🤌', '🤏',
      '🫰', '🦶', '🦵', '🤛', '🤜', '🫸', '🫷'
    ];

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Stack(
          children: List.generate(45, (index) {
            final int group = index % 4;
            double offsetX, offsetY, opacity, rotation;

            if (group == 0) {
              final angle = animationController.value * 2 * math.pi + (index * math.pi / 7);
              final radius = 40 + (index % 5) * 15;
              offsetX = radius * math.cos(angle);
              offsetY = radius * math.sin(angle);
              opacity = 0.15 + 0.1 * math.sin(animationController.value * math.pi + index);
              rotation = angle;
            } else if (group == 1) {
              offsetX = 50 * math.sin(animationController.value * 2 * math.pi + index / 3);
              offsetY = 30 * math.cos(animationController.value * 2 * math.pi + index / 5);
              opacity = 0.18 + 0.12 * math.cos(animationController.value * math.pi + index / 2);
              rotation = math.pi / 4 * math.sin(animationController.value * math.pi + index / 2);
            } else if (group == 2) {
              final pulse = 0.5 + 0.5 * math.sin(animationController.value * 2 * math.pi + index / 4);
              offsetX = 25 * math.sin(pulse * math.pi + index);
              offsetY = 25 * math.cos(pulse * math.pi + index);
              opacity = 0.1 + 0.15 * pulse;
              rotation = math.pi * pulse;
            } else {
              final zigzag = math.sin(animationController.value * 3 * math.pi + index / 2);
              offsetX = 40 * zigzag;
              offsetY = 20 * math.cos(animationController.value * 4 * math.pi + index / 3);
              opacity = 0.14 + 0.12 * zigzag.abs();
              rotation = math.pi / 6 * zigzag;
            }

            final double left = ((index * 67) % (size.width - 50)) + 25;
            final double top = ((index * 83) % (size.height - 50)) + 25;

            final baseSize = 24 + (index % 5) * 6;
            final sizeVariation = group == 2
                ? baseSize * (0.8 + 0.4 * math.sin(animationController.value * math.pi + index / 2))
                : baseSize;

            return Positioned(
              left: left + offsetX,
              top: top + offsetY,
              child: Transform.rotate(
                angle: rotation,
                child: Opacity(
                  opacity: opacity,
                  child: Text(
                    handEmojis[index % handEmojis.length],
                    style: TextStyle(fontSize: sizeVariation.toDouble()),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
