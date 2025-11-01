// lib/screens/training_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:placepro/screens/course_detail_screen.dart';
import 'package:placepro/screens/drives_screen.dart';
import 'package:placepro/screens/notes_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:placepro/config/mongodb_config.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  TrainingScreenState createState() => TrainingScreenState();
}

class TrainingScreenState extends State<TrainingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Courses'),
            Tab(text: 'Drives'),
            Tab(text: 'Notes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CoursesTab(),
          DrivesTab(),
          NotesTab(),
        ],
      ),
    );
  }
}

class CoursesTab extends StatefulWidget {
  const CoursesTab({super.key});

  @override
  State<CoursesTab> createState() => CoursesTabState();
}

class CoursesTabState extends State<CoursesTab> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      // Force refresh token to avoid using a stale/invalid token
      final token = user != null ? await user.getIdToken(true) : null;
      final resp = await http.get(
        Uri.parse('${MongoDBConfig.baseUrl}${MongoDBConfig.coursesEndpoint}'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
      }
      if (!mounted) return;
      final List<dynamic> data = json.decode(resp.body);
      setState(() {
        _courses = data.map((course) => {
              'id': course['_id'] ?? course['id'],
              'title': course['title'] ?? '',
              'description': course['description'] ?? '',
              'duration': course['duration'] ?? '',
              'trainer': course['instructor']?['displayName'] ?? 'Unknown',
              'topics': course['topics'] ?? [],
            }).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load courses', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _fetchCourses, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No courses available'),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _fetchCourses, child: const Text('Refresh')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCourses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final courseData = _courses[index];
          final courseId = courseData['id'];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailScreen(
                      courseId: courseId,
                      courseData: courseData,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseData['title'] ?? 'Course Title',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Trainer: ${courseData['trainer'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Duration: ${courseData['duration'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress bar (kept using Firestore progress collection)
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('progress')
                          .doc(user?.uid)
                          .collection('courses')
                          .doc(courseId)
                          .snapshots(),
                      builder: (context, progressSnapshot) {
                        double progress = 0.0;
                        if (progressSnapshot.hasData && progressSnapshot.data!.exists) {
                          var progressData = progressSnapshot.data!.data() as Map<String, dynamic>;
                          int completed = progressData['completedTopics'] ?? 0;
                          int total = progressData['totalTopics'] ?? 1;
                          progress = total > 0 ? completed / total : 0.0;
                        }
                        return Column(
                          children: [
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(progress * 100).toInt()}% Complete',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DrivesTab extends StatelessWidget {
  const DrivesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const DrivesScreen();
  }
}

class NotesTab extends StatelessWidget {
  const NotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotesScreen();
  }
}