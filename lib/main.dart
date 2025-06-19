import 'package:flutter/material.dart';
import 'package:silent_talk_app/screen/home_screen.dart';
import 'package:silent_talk_app/screen/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silent Talk',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}