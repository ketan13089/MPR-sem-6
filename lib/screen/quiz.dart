import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hand Sign Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF8B5A2B), // Badam/Almond color
        scaffoldBackgroundColor: const Color(0xFF362511), // Dark badam
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF5DEB3), // Wheat/cream
          secondary: Color(0xFFD2B48C), // Tan
          surface: Color(0xFF4A3319), // Dark badam shade
          // Removed deprecated 'background' property
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Color(0xFFF5DEB3)),
          headlineMedium: TextStyle(color: Color(0xFFF5DEB3)),
          bodyLarge: TextStyle(color: Color(0xFFF5DEB3)),
          bodyMedium: TextStyle(color: Color(0xFFF5DEB3)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5A2B),
            foregroundColor: const Color(0xFFF5DEB3),
          ),
        ),
      ),
      home: const QuizScreen(),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _coins = 0;
  bool _quizCompleted = false;
  bool _showConfetti = false;
  late AnimationController _confettiController;
  final List<Color> _confettiColors = const [
    Colors.amber,
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  final List<Map<String, dynamic>> _questions = [
    {
      'image': 'assets/signs/a.png',
      'question': 'What letter is this hand sign representing?',
      'options': ['A', 'B', 'C', 'D'],
      'correctAnswer': 'A',
    },
    {
      'image': 'assets/signs/hello.png',
      'question': 'What greeting does this hand sign represent?',
      'options': ['Goodbye', 'Hello', 'Thank you', 'Please'],
      'correctAnswer': 'Hello',
    },
    {
      'image': 'assets/signs/thank_you.png',
      'question': 'What does this hand sign mean?',
      'options': ['Yes', 'No', 'Thank you', 'Sorry'],
      'correctAnswer': 'Thank you',
    },
    {
      'image': 'assets/signs/peace.png',
      'question': 'What concept does this hand sign represent?',
      'options': ['Peace', 'Victory', 'Number 2', 'All of the above'],
      'correctAnswer': 'All of the above',
    },
    {
      'image': 'assets/signs/i_love_you.png',
      'question': 'What emotion does this hand sign convey?',
      'options': ['Joy', 'Love', 'Sadness', 'Anger'],
      'correctAnswer': 'Love',
    },
    {
      'image': 'assets/signs/number_5.png',
      'question': 'What number is shown in this hand sign?',
      'options': ['3', '4', '5', '6'],
      'correctAnswer': '5',
    },
    {
      'image': 'assets/signs/nice.png',
      'question': 'What message does this hand sign communicate?',
      'options': ['Perfect', 'Nice', 'Bad', 'All of the above'],
      'correctAnswer': 'Bad',
    },
    {
      'image': 'assets/signs/stop.png',
      'question': 'What action does this hand sign indicate?',
      'options': ['Go', 'Stop', 'Wait', 'Listen'],
      'correctAnswer': 'Stop',
    },
    {
      'image': 'assets/signs/thumbs_up.png',
      'question': 'What does this thumbs up sign represent?',
      'options': ['Approval', 'Direction', 'Number 1', 'Agreement'],
      'correctAnswer': 'Approval',
    },
    {
      'image': 'assets/signs/rock_on.png',
      'question': 'In which context is this hand sign commonly used?',
      'options': ['Business meetings', 'Rock concerts', 'Academic settings', 'Religious ceremonies'],
      'correctAnswer': 'Rock concerts',
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _confettiController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showConfetti = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkAnswer(String selectedOption) {
    bool isCorrect = selectedOption == _questions[_currentQuestionIndex]['correctAnswer'];
    
    if (isCorrect) {
      setState(() {
        _score++;
      });
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    setState(() {
      _quizCompleted = true;
      double percentage = (_score / _questions.length) * 100;
      
      if (percentage >= 70) {
        _showConfetti = true;
        _confettiController.forward(from: 0.0);
        
        // Award coins based on performance
        if (percentage >= 90) {
          _coins = 100;
        } else if (percentage >= 80) {
          _coins = 50;
        } else {
          _coins = 25;
        }
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _quizCompleted = false;
      _showConfetti = false;
      _confettiController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hand Sign Detection Quiz',
          style: TextStyle(color: Color(0xFFF5DEB3)),
        ),
        backgroundColor: const Color(0xFF4A3319),
      ),
      body: Stack(
        children: [
          Center(
            child: _quizCompleted ? _buildResultScreen() : _buildQuizScreen(),
          ),
          if (_showConfetti) _buildConfetti(),
        ],
      ),
    );
  }

  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        final deviceSize = MediaQuery.of(context).size;
        const confettiCount = 50;
        final List<Widget> confettiPieces = [];
        
        for (int i = 0; i < confettiCount; i++) {
          final random = Random();
          final color = _confettiColors[random.nextInt(_confettiColors.length)];
          final pieceSize = random.nextDouble() * 10 + 5;
          final left = random.nextDouble() * deviceSize.width;
          final animValue = _confettiController.value;
          final top = deviceSize.height * (animValue - random.nextDouble() * 0.2);
          
          confettiPieces.add(
            Positioned(
              left: left,
              top: top,
              child: Transform.rotate(
                angle: random.nextDouble() * 6.28,
                child: Container(
                  width: pieceSize,
                  height: pieceSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: random.nextBool() ? BoxShape.circle : BoxShape.rectangle,
                  ),
                ),
              ),
            ),
          );
        }
        
        return Stack(children: confettiPieces);
      },
    );
  }

  Widget _buildQuizScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: const Color(0xFF362511),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5A2B)),
          ),
          const SizedBox(height: 16),
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
            style: const TextStyle(fontSize: 16, color: Color(0xFFD2B48C)),
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF4A3319),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8B5A2B), width: 2),
            ),
            child: Center(
              child: Image.asset(
                _questions[_currentQuestionIndex]['image'],
                height: 180,
                fit: BoxFit.contain,
                // Note: Replace with placeholder since actual images aren't available
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.sign_language, size: 120, color: Theme.of(context).colorScheme.primary);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _questions[_currentQuestionIndex]['question'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ..._questions[_currentQuestionIndex]['options'].map<Widget>((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () => _checkAnswer(option),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(option, style: const TextStyle(fontSize: 18)),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (_score / _questions.length) * 100;
    final passed = percentage >= 70;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            passed ? 'Congratulations!' : 'Quiz Completed',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4A3319),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8B5A2B), width: 2),
            ),
            child: Column(
              children: [
                const Text(
                  'Your Score',
                  style: TextStyle(fontSize: 22, color: Color(0xFFD2B48C)),
                ),
                const SizedBox(height: 16),
                Text(
                  '$_score/${_questions.length}',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFF5DEB3)),
                ),
                const SizedBox(height: 8),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.bold,
                    color: passed ? const Color(0xFF90EE90) : const Color(0xFFFF6961),
                  ),
                ),
                if (passed) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '$_coins coins earned!',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _restartQuiz,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}