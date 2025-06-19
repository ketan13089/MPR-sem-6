import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlphabetLearningPage extends StatefulWidget {
  const AlphabetLearningPage({Key? key}) : super(key: key);

  @override
  State<AlphabetLearningPage> createState() => _AlphabetLearningPageState();
}

class _AlphabetLearningPageState extends State<AlphabetLearningPage> with SingleTickerProviderStateMixin {
  // Animation controller for background effects
  late AnimationController _animationController;
  
  // Current selected letter index (0-25 for A-Z)
  int _currentLetterIndex = 0;
  
  // Audio player for voice guidance
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Track learned letters
  Set<int> _learnedLetters = {};
  
  // Loading status
  bool _isLoading = true;
  
  // List of all alphabet letters
  final List<String> _alphabets = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  final List<String> _sign = [
    'assets/signs/a.png',
    'assets/signs/b.png',
    'assets/signs/c.png',
    'assets/signs/d.png',
    'assets/signs/e.png',
    'assets/signs/f.png',
    'assets/signs/g.png',
    'assets/signs/h.png',
    'assets/signs/i.png',
    'assets/signs/j.png',
    'assets/signs/k.png',
    'assets/signs/l.png',
    'assets/signs/m.png',
    'assets/signs/n.png',
    'assets/signs/o.png',
    'assets/signs/p.png',
    'assets/signs/q.png',
    'assets/signs/r.png',
    'assets/signs/s.png',
    'assets/signs/t.png',
    'assets/signs/u.png',
    'assets/signs/v.png',
    'assets/signs/w.png',
    'assets/signs/x.png',
    'assets/signs/y.png',
    'assets/signs/z.png',
  ];


  // Step-by-step instructions for each letter (dummy data for 5 letters)
  final Map<String, List<String>> _letterInstructions = {
    'A': [
      'Start with a closed fist pointing upwards',
      'Keep your thumb at the side of your fist',
      'This is the sign for "A"'
    ],
    'B': [
      'Start with an open palm facing forward',
      'Fold your thumb across your palm',
      'Keep your fingers straight and together',
      'This is the sign for "B"'
    ],
    'C': [
      'Form a "C" shape with your hand',
      'Cup your fingers and thumb together',
      'Keep your palm facing to the side',
      'This is the sign for "C"'
    ],
    'D': [
      'Make a circle with your thumb and middle finger',
      'Extend your index finger upwards',
      'Keep other fingers curled',
      'This is the sign for "D"'
    ],
    'E': [
      'Start with a closed fist pointing upwards',
      'Curl your fingers inward',
      'Rest your thumb against your fingertips',
      'This is the sign for "E"'
    ],
    'F': [
      'Join the tip of your index finger and thumb to form a ring',
      'Keep the other fingers extended upwards',
      'Palm facing forward',
      'This is the sign for "F"'
    ],
    'G': [
      'Point your index finger to the side',
      'Keep your thumb pointing up, making an "L" shape',
      'Curl the other fingers into your palm',
      'This is the sign for "G"'
    ],
    'H': [
      'Extend your index and middle finger together',
      'Palm facing sideways',
      'Curl the rest of the fingers into the palm',
      'This is the sign for "H"'
    ],
    'I': [
      'Raise your pinky finger upward',
      'Keep the rest of the fingers in a fist',
      'This is the sign for "I"'
    ],
    'J': [
      'Start with the "I" sign',
      'Use your pinky to draw a "J" in the air',
      'This is the sign for "J"'
    ],
    'K': [
      'Extend your index and middle finger upward in a V shape',
      'Place your thumb between them',
      'Palm facing forward',
      'This is the sign for "K"'
    ],
    'L': [
      'Form an "L" shape with your thumb and index finger',
      'Keep the other fingers folded down',
      'Palm facing forward',
      'This is the sign for "L"'
    ],
    'M': [
      'Place your thumb between your pinky and ring finger',
      'Curl all fingers over the thumb',
      'This is the sign for "M"'
    ],
    'N': [
      'Place your thumb between your middle and ring finger',
      'Curl all fingers over the thumb',
      'This is the sign for "N"'
    ],
    'O': [
      'Form an "O" shape using all your fingers',
      'Bring fingertips together in a circle',
      'Palm facing outward',
      'This is the sign for "O"'
    ],
    'P': [
      'Make a "K" sign',
      'Tilt your hand downward',
      'Palm facing the ground',
      'This is the sign for "P"'
    ],
    'Q': [
      'Point your index finger downward',
      'Place your thumb on top of it',
      'Curl other fingers in',
      'This is the sign for "Q"'
    ],
    'R': [
      'Cross your middle finger over your index finger',
      'Palm facing forward',
      'This is the sign for "R"'
    ],
    'S': [
      'Make a closed fist',
      'Place your thumb across the front of the fingers',
      'Palm facing forward',
      'This is the sign for "S"'
    ],
    'T': [
      'Place your thumb between your index and middle finger',
      'Curl the rest of your fingers into a fist',
      'This is the sign for "T"'
    ],
    'U': [
      'Extend your index and middle finger together',
      'Keep the other fingers curled in',
      'Palm facing forward',
      'This is the sign for "U"'
    ],
    'V': [
      'Raise your index and middle finger in a "V" shape',
      'Palm facing forward',
      'This is the sign for "V"'
    ],
    'W': [
      'Raise your index, middle, and ring fingers',
      'Spread them to form a "W"',
      'Keep your pinky and thumb down',
      'Palm facing forward',
      'This is the sign for "W"'
    ],
    'X': [
      'Curl your index finger to make a hook shape',
      'Keep the rest of the fingers curled',
      'Palm facing forward',
      'This is the sign for "X"'
    ],
    'Y': [
      'Extend your thumb and pinky finger',
      'Curl the other fingers into the palm',
      'Palm facing forward',
      'This is the sign for "Y"'
    ],
    'Z': [
      'Raise your index finger',
      'Use it to draw a "Z" shape in the air',
      'This is the sign for "Z"'
    ],
  };


  // Dummy voice prompts (would be actual asset paths in production)
  final Map<String, String> _voiceAssets = {
    'A': 'assets/audio/letter_a.mp3',
    'B': 'assets/audio/letter_b.mp3',
    'C': 'assets/audio/letter_c.mp3',
    'D': 'assets/audio/letter_d.mp3',
    'E': 'assets/audio/letter_e.mp3',
  };
  
  // Initialize
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    
    _loadLearningProgress();
  }
  
  // Load saved progress
  Future<void> _loadLearningProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final learnedLettersIndices = prefs.getStringList('learned_letters') ?? [];
    
    setState(() {
      _learnedLetters = learnedLettersIndices.map((e) => int.parse(e)).toSet();
      _isLoading = false;
    });
  }
  
  // Save learning progress
  Future<void> _saveLearningProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final learnedLettersIndices = _learnedLetters.map((e) => e.toString()).toList();
    await prefs.setStringList('learned_letters', learnedLettersIndices);
  }
  
  // Mark current letter as learned
  void _markAsLearned() {
    setState(() {
      _learnedLetters.add(_currentLetterIndex);
    });
    _saveLearningProgress();
    
    // Check if 5 new letters learned (for quiz trigger)
    if (_learnedLetters.length % 5 == 0) {
      _showQuizPrompt();
    }
  }
  
  // Show quiz prompt after learning 5 letters
  void _showQuizPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5EFE0),
          title: const Text(
            "Ready for a Quiz?",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "You've learned 5 new letters! Would you like to test your knowledge with a quick quiz?",
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Later",
                style: TextStyle(color: Color(0xFFDA9F74)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDA9F74),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to quiz (would be implemented)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Quiz feature coming soon!"),
                    backgroundColor: Color(0xFFDA9F74),
                  ),
                );
              },
              child: const Text("Start Quiz"),
            ),
          ],
        );
      },
    );
  }
  
  // Play voice guidance
  void _playVoiceGuidance() {
    final letter = _alphabets[_currentLetterIndex];
    if (_voiceAssets.containsKey(letter)) {
      // In a real app, you would load the actual audio file
      // For this demo, we'll just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Playing: This is the sign for $letter"),
          backgroundColor: const Color(0xFFDA9F74),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Actual implementation would be:
      // _audioPlayer.play(AssetSource(_voiceAssets[letter]!));
    }
  }
  
  // Navigate to previous letter
  void _goToPreviousLetter() {
    if (_currentLetterIndex > 0) {
      setState(() {
        _currentLetterIndex--;
      });
    }
  }
  
  // Navigate to next letter
  void _goToNextLetter() {
    if (_currentLetterIndex < _alphabets.length - 1) {
      setState(() {
        _currentLetterIndex++;
      });
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final currentLetter = _alphabets[_currentLetterIndex];
    final currentsign = _sign[_currentLetterIndex];
    //final bool hasInstructions = _letterInstructions.containsKey(currentLetter);
    final List<String> instructions = _letterInstructions[currentLetter] ??
        ["Instructions not available for this letter"];


    
    // Calculate learning progress percentage
    final double progressPercentage = _learnedLetters.isEmpty 
        ? 0 
        : (_learnedLetters.length / _alphabets.length);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6C9A8),
        elevation: 0,
        title: const Text(
          "Learn Alphabets (A-Z)",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Downloading all signs for offline use..."),
                  backgroundColor: Color(0xFFDA9F74),
                ),
              );
            },
            tooltip: "Download for offline use",
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDA9F74)))
          : Stack(
        children: [
          // Background with corner radial gradients
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              color: Color(0xFFF5EFE0), // Slightly deeper cream base color
            ),
          ),
          
          // Top-left corner gradient
          Positioned(
            top: -size.width * 0.3,
            left: -size.width * 0.3,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: size.width * 0.8,
                  height: size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color.lerp(const Color(0xFFE6C9A8), const Color(0xFFD9BFA0), _animationController.value)!, // Deeper badam
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Bottom-right corner gradient
          Positioned(
            bottom: -size.width * 0.3,
            right: -size.width * 0.3,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: size.width * 0.8,
                  height: size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color.lerp(const Color(0xFFFFCFA0), const Color(0xFFFFDAB3), _animationController.value)!, // Deeper peach to badam
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Your Progress",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "${(_learnedLetters.length)} / ${_alphabets.length} Letters",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            // Background
                            Container(
                              height: 10,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            // Progress
                            Container(
                              height: 10,
                              width: MediaQuery.of(context).size.width * progressPercentage * 0.91, // Adjusting for padding
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE6BA90), // Deeper start color
                                    Color(0xFFFFB980), // Deeper end color
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Alphabet selection strip
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _alphabets.length,
                      itemBuilder: (context, index) {
                        final bool isLearned = _learnedLetters.contains(index);
                        final bool isSelected = index == _currentLetterIndex;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentLetterIndex = index;
                            });
                          },
                          child: Container(
                            width: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFDA9F74)
                                  : (isLearned ? const Color(0xFFFFCB94) : Colors.white.withValues(alpha: 0.6)),
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: Colors.black87, width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _alphabets[index],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: isSelected || isLearned ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Main Content Area
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Letter display
                          Text(
                            currentLetter,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDA9F74),
                              shadows: [
                                Shadow(
                                  blurRadius: 2.0,
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Sign animation/image
                          Expanded(
                            flex: 2,
                            child: Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                // This would be a GIF or 3D model viewer in production
                                child: Center(
                                  child: Image.asset(
                                    currentsign,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.contain,
                                  )
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Step-by-step instructions
                          Expanded(
                            flex: 1,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD199).withAlpha(200),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFFB980),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Instructions:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: instructions.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${index + 1}. ",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  instructions[index],
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Voice pronunciation
                              ElevatedButton.icon(
                                icon: const Icon(Icons.volume_up),
                                label: const Text("Hear Sign"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE6BA90),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _playVoiceGuidance,
                              ),
                              
                              // Mark as learned
                              ElevatedButton.icon(
                                icon: Icon(
                                  _learnedLetters.contains(_currentLetterIndex)
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                ),
                                label: Text(
                                  _learnedLetters.contains(_currentLetterIndex)
                                      ? "Learned"
                                      : "Mark Learned"
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _learnedLetters.contains(_currentLetterIndex)
                                      ? const Color(0xFF8BC34A)
                                      : const Color(0xFFDA9F74),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  if (!_learnedLetters.contains(_currentLetterIndex)) {
                                    _markAsLearned();
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Navigation buttons
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous letter button
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text("Previous"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentLetterIndex > 0
                    ? const Color(0xFFE6BA90)
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _currentLetterIndex > 0 ? _goToPreviousLetter : null,
            ),
            
            // Letter indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD199).withAlpha(200),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFB980),
                  width: 1.5,
                ),
              ),
              child: Text(
                "${_currentLetterIndex + 1}/${_alphabets.length}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // Next letter button
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Next"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentLetterIndex < _alphabets.length - 1
                    ? const Color(0xFFDA9F74)
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _currentLetterIndex < _alphabets.length - 1 ? _goToNextLetter : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Extension method to set alpha value for colors
extension ColorExtension on Color {
  Color withValues({int alpha = 255}) {
    return Color.fromARGB(alpha, r.toInt(), g.toInt(), b.toInt());
  }
}