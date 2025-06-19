import 'package:flutter/material.dart';
import 'package:silent_talk_app/screen/join_room_screen.dart';
import 'package:silent_talk_app/screen/test1.dart';
import 'dart:math' as math;
import 'learn.dart';
import 'quiz.dart';
import 'detect.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  // User data - would be fetched from your database
  final String userName = "Ketan";
  final bool isOfflineMode = false;

  // Progress data - would be fetched from your database
  final int signsLearned = 5;
  final int totalSigns = 26;
  final int quizAccuracy = 80;
  final int streakDays = 3;

  // Word of the day data - would be fetched from your database
  final String wordOfTheDay = "Love";
  final String signEmoji = "🤟";

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background with corner radial gradients
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              color: Color(0xFFF5EFE0), // Very light cream base color
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
                        Color.lerp(
                            const Color(0xFFEFDBC5),
                            const Color(0xFFD9BFA0),
                            _animationController.value)!, // Light badam
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
                        Color.lerp(
                            const Color(0xFFFFDCB9),
                            const Color(0xFFFFE8CC),
                            _animationController
                                .value)!, // Light peach to badam
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Animated hand gesture emojis in background
          _buildHandGesturesBackground(),

          // Main content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                title: const Text(
                  "Silent Talk",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.black87),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.black87),
                    onPressed: () {},
                  ),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // 1. Personalized Greeting
                      _buildGreetingSection(),

                      const SizedBox(height: 24),

                      // 2. Quick Actions
                      _buildQuickActionsSection(),

                      const SizedBox(height: 24),

                      // 3. Today's Progress Widget
                      _buildProgressSection(),

                      const SizedBox(height: 24),

                      // 4. Word of the Day Section
                      _buildWordOfTheDaySection(),

                      // Extra padding at bottom for scroll
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 5. Offline Mode Notification (if enabled)
          if (isOfflineMode)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.black87,
                child: const Row(
                  children: [
                    Icon(
                      Icons.cloud_off,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "You're in Offline Mode. Some features may be limited.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      drawer: _buildDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEFDBC5),
        foregroundColor: Colors.black87,
        onPressed: () {
          // Open camera for live sign detection
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  // Hand gestures background animation
  Widget _buildHandGesturesBackground() {
    final Size size = MediaQuery.of(context).size;

    // List of hand gesture emojis
    final List<String> handEmojis = [
      '👋',
      '✌',
      '👍',
      '👏',
      '🤝',
      '🙌',
      '👐',
      '🤲',
      '✋',
      '🤚',
      '🖐',
      '👌',
      '🤞',
      '🤟',
      '🤙'
    ];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            // Generate random positions for each emoji
            final double left = (index * size.width / 8) % size.width;
            final double top = ((index * 73) % size.height);

            // Create different animation paths for each emoji
            final double offsetX =
                30 * math.sin(_animationController.value * 2 * math.pi + index);
            final double offsetY = 20 *
                math.cos(_animationController.value * 2 * math.pi + index / 2);

            return Positioned(
              left: left + offsetX,
              top: top + offsetY,
              child: Opacity(
                opacity: 0.15, // Low opacity as requested
                child: Text(
                  handEmojis[index % handEmojis.length],
                  style: TextStyle(
                    fontSize: 24 + (index % 3) * 8, // Varying sizes
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // 1. Personalized Greeting Section
  Widget _buildGreetingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Hello, $userName ",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Text(
                "👋",
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Let's make silence speak.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Quick Actions Section
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildFeatureCard(
              icon: Icons.sign_language,
              title: "Learn Signs",
              subtitle: "Master the basics",
              color: const Color(0xFFFFDCB9),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlphabetLearningPage(),
                  ),
                );
              },
            ),
            _buildFeatureCard(
              icon: Icons.quiz,
              title: "Take Quiz",
              subtitle: "Test your knowledge",
              color: const Color(0xFFFFE0B2),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizScreen()),
                );
              },
            ),
            _buildFeatureCard(
              icon: Icons.videocam,
              title: "Video Meet",
              subtitle: "Connect with others",
              color: const Color(0xFFEFDBC5),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const JoinRoomScreen()),
                );
              },
            ),
            _buildFeatureCard(
              icon: Icons.assignment,
              title: "Daily Practice",
              subtitle: "Build your skills",
              color: const Color(0xFFF8E9C6),
              onTap: () {},
            ),
            _buildFeatureCard(
              icon: Icons.camera_alt,
              title: "Live Sign Detection",
              subtitle: "Real-time translation",
              color: const Color(0xFFFFE8CC),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HandSignDetectionPage1(),
                  ),
                );
              },
            ),
            _buildFeatureCard(
              icon: Icons.bar_chart,
              title: "Progress Tracker",
              subtitle: "Track your journey",
              color: const Color(0xFFE6D2B5),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: color.withValues(
                  alpha: 0.7 + 0.3 * _animationController.value),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.black87,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Progress Section
  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF8E1),
            Color(0xFFFFE0B2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFEFDBC5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: Colors.black87,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Today's Progress",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFDBC5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.deepOrange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$streakDays day streak",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  icon: Icons.sign_language,
                  title: "Signs learned",
                  value: "$signsLearned/$totalSigns",
                  progress: signsLearned / totalSigns,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  icon: Icons.quiz,
                  title: "Quiz accuracy",
                  value: "$quizAccuracy%",
                  progress: quizAccuracy / 100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required String title,
    required String value,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Background
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Progress
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * 0.5 * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEFDBC5),
                        Color.lerp(
                            const Color(0xFFEFDBC5),
                            const Color(0xFFFFDCB9),
                            _animationController.value)!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // 4. Word of the Day Section
  Widget _buildWordOfTheDaySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0B2).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE6D2B5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.black87,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Word of the Day",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wordOfTheDay,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tap to learn how to sign",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          spreadRadius: 2 * _animationController.value,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        signEmoji,
                        style: const TextStyle(
                          fontSize: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: const BorderSide(color: Color(0xFFEFDBC5)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_outline, size: 18),
                SizedBox(width: 8),
                Text("Watch Tutorial"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFEFDBC5),
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            activeIcon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam_outlined),
            activeIcon: Icon(Icons.videocam),
            label: 'Meet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  // Drawer
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: const Color(0xFFFFF8E1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFEFDBC5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white70,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFFEFDBC5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Silent Talk User",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.home_outlined,
              title: 'Home',
              isSelected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.school_outlined,
              title: 'Learn Signs',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.quiz_outlined,
              title: 'Take Quiz',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.videocam_outlined,
              title: 'Video Meet',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RoomSelectionPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.assignment_outlined,
              title: 'Daily Practice',
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.camera_alt_outlined,
              title: 'Live Sign Detection',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HandSignDetectionPage1()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.bar_chart_outlined,
              title: 'Progress Tracker',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.logout_outlined,
              title: 'Sign Out',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFFEFDBC5) : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.black87 : Colors.black54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFFFFE0B2).withValues(alpha: 0.3),
      onTap: onTap,
    );
  }
}

class RoomSelectionPage extends StatelessWidget {
  const RoomSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _roomIdController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        backgroundColor: const Color(0xFFEFDBC5),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5EFE0),
              Color(0xFFEFDBC5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _roomIdController,
                decoration: InputDecoration(
                  labelText: 'Room ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.meeting_room),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () =>
                    _joinRoom(context, _roomIdController.text, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9BFA0),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Join Room',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => _joinRoom(context, '', true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFDBC5),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create New Room',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _joinRoom(BuildContext context, String roomId, bool isCaller) {
    if (roomId.isEmpty && !isCaller) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a room ID'),
          backgroundColor: Color(0xFFEFDBC5),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (isCaller) {
      roomId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => HandSignDetectionPage(
    //       roomId: roomId,
    //       isCaller: isCaller,
    //     ),
    //   ),
    // );
  }
}

// Add this extension to fix the RTCVideoRenderer issue
extension RTCVideoRendererFix on RTCVideoRenderer {
  RTCVideoValue get videoValue => value;
}
