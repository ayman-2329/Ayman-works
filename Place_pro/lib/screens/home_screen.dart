// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:placepro/screens/profile_screen.dart';
import 'package:placepro/screens/training_screen.dart';
import 'package:placepro/screens/aplitude_screen.dart';
import 'package:placepro/screens/logical_reasoning_screen.dart';
import 'package:placepro/screens/ai_bot_screen.dart';
import 'package:placepro/screens/drives_screen.dart';
import 'package:placepro/screens/notes_screen.dart';
import 'package:placepro/screens/calendar_screen.dart';
import 'package:placepro/widgets/ai_tip_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(
        onTabTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const TrainingScreen(),
      const AptitudeScreen(),
      const LogicalReasoningScreen(),
      const AIBotScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
  // final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlacePro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Training',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Aptitude',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.extension),
            label: 'Logical',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'AI Bot',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final Function(int) onTabTapped;
  
  const HomeContent({super.key, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
  // final authService = Provider.of<AuthService>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Welcome to PlacePro!'),
                  ),
                );
              }
              
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              String name = userData['name'] ?? 'Student';
              
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi $name 👋',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Welcome to PlacePro, your guide to placement success!',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Featured Courses
          const Text(
            'Featured Courses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('courses')
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No courses available'));
                }
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var course = snapshot.data!.docs[index];
                    var courseData = course.data() as Map<String, dynamic>;
                    
                    return Card(
                      margin: const EdgeInsets.only(right: 16),
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              courseData['title'] ?? 'Course Title',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Trainer: ${courseData['trainer'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Duration: ${courseData['duration'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigate to course details
                                },
                                child: const Text('View'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // AI-Powered Daily Tip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI Tip of the Day',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  // Refresh tip functionality will be handled by the widget
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const AITipCard(),
          
          const SizedBox(height: 24),
          
          // Quick Links
          const Text(
            'Quick Links',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildQuickLinkCard(
                context,
                'Active Drives',
                Icons.business_center,
                const Color(0xFF4285F4), // Google Blue
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DrivesScreen(),
                    ),
                  );
                },
              ),
              _buildQuickLinkCard(
                context,
                'Aptitude Tests',
                Icons.psychology,
                const Color(0xFF0F9D58), // Google Green
                () {
                  onTabTapped(2); // Navigate to Aptitude tab
                },
              ),
              _buildQuickLinkCard(
                context,
                'Logical Reasoning',
                Icons.extension,
                const Color(0xFFDB4437), // Google Red
                () {
                  onTabTapped(3); // Navigate to Logical Reasoning tab
                },
              ),
              _buildQuickLinkCard(
                context,
                'Study Materials',
                Icons.library_books,
                const Color(0xFFFFA000), // Amber
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotesScreen(),
                    ),
                  );
                },
              ),
              _buildQuickLinkCard(
                context,
                'Training',
                Icons.school,
                const Color(0xFF9C27B0), // Purple
                () {
                  onTabTapped(1); // Navigate to Training tab
                },
              ),
              _buildQuickLinkCard(
                context,
                'Calendar',
                Icons.calendar_today,
                const Color(0xFF2196F3), // Light Blue
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarScreen(),
                    ),
                  );
                },
              ),
              _buildQuickLinkCard(
                context,
                'AI Assistant',
                Icons.smart_toy,
                const Color(0xFF607D8B), // Blue Grey
                () {
                  onTabTapped(4); // Navigate to AI Bot tab
                },
              ),
              _buildQuickLinkCard(
                context,
                'Profile',
                Icons.person,
                const Color(0xFF795548), // Brown
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickLinkCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withAlpha(230),
                color.withAlpha(179),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(77),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}