// lib/screens/course_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/mongodb_config.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic> courseData;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.courseData,
  });

  @override
  CourseDetailScreenState createState() => CourseDetailScreenState();
}

class CourseDetailScreenState extends State<CourseDetailScreen> {
  late Future<List<Map<String, dynamic>>> _topicsFuture;
  int _completedTopics = 0;
  int _totalTopics = 0;

  @override
  void initState() {
    super.initState();
    _topicsFuture = _fetchTopicsFromBackend();
    _loadProgress();
  }

  Future<List<Map<String, dynamic>>> _fetchTopicsFromBackend() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = user != null ? await user.getIdToken() : null;
      final uri = Uri.parse(
          '${MongoDBConfig.baseUrl}${MongoDBConfig.coursesEndpoint}/${widget.courseId}/topics');
      final resp = await http.get(
        uri,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (resp.statusCode != 200) {
        throw Exception('Failed to load topics: ${resp.statusCode} ${resp.body}');
      }
      final List<dynamic> data = json.decode(resp.body);
      // Each topic: { title, content (JSON string), order, duration }
      final topics = data.map<Map<String, dynamic>>((t) {
        Map<String, dynamic>? contentObj;
        final content = t['content'];
        if (content is String) {
          try {
            contentObj = json.decode(content) as Map<String, dynamic>;
          } catch (_) {
            contentObj = {'text': content};
          }
        } else if (content is Map<String, dynamic>) {
          contentObj = content;
        }
        return {
          'id': (t['id']?.toString()) ?? (t['_id']?.toString()) ?? (t['order']?.toString() ?? ''),
          'title': t['title'] ?? 'Topic',
          'order': t['order'] ?? 0,
          'duration': t['duration'] ?? 0,
          'content': contentObj,
        };
      }).toList()
        ..sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));

      // set total topics
      if (mounted) {
        setState(() {
          _totalTopics = topics.length;
        });
      }
      return topics;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot progressDoc = await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('courses')
          .doc(widget.courseId)
          .get();
      if (progressDoc.exists) {
        var progressData = progressDoc.data() as Map<String, dynamic>;
        setState(() {
          _completedTopics = progressData['completedTopics'] ?? 0;
          _totalTopics = progressData['totalTopics'] ?? 0;
        });
      }
    }
  }

  Future<void> _markTopicComplete(String topicId, bool isCompleted) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference progressRef = FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('courses')
          .doc(widget.courseId);
      DocumentSnapshot progressDoc = await progressRef.get();
      if (progressDoc.exists) {
        var progressData = progressDoc.data() as Map<String, dynamic>;
        int completed = progressData['completedTopics'] ?? 0;
        if (isCompleted) {
          completed++;
        } else {
          completed--;
        }
                await progressRef.update({
          'completedTopics': completed,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        setState(() {
          _completedTopics = completed;
        });
      } else {
        await progressRef.set({
          'completedTopics': isCompleted ? 1 : 0,
          'totalTopics': _totalTopics,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        setState(() {
          _completedTopics = isCompleted ? 1 : 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseData['title'] ?? 'Course Details'),
      ),
      body: Column(
        children: [
          // Course Header
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.courseData['title'] ?? 'Course Title',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Trainer: ${widget.courseData['trainer'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: ${widget.courseData['duration'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _totalTopics > 0 ? _completedTopics / _totalTopics : 0,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_totalTopics > 0 ? (_completedTopics / _totalTopics * 100).toInt() : 0}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text('$_completedTopics of $_totalTopics topics completed'),
              ],
            ),
          ),
          // Topics List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _topicsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final topics = snapshot.data ?? [];
                if (topics.isEmpty) {
                  return const Center(child: Text('No topics available'));
                }
                if (_totalTopics == 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _totalTopics = topics.length);
                  });
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    final topicId = topic['id']?.toString() ?? index.toString();
                    final title = topic['title'] ?? 'Topic Title';
                    final content = topic['content'] as Map<String, dynamic>?;
                    final code = content?['codeExample']?['code'] as String?;
                    final text = content?['text'] as String?;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(
                          Icons.menu_book,
                          color: Colors.blue,
                          size: 32,
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: text != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : null,
                        trailing: Checkbox(
                          value: false,
                          onChanged: (value) {
                            _markTopicComplete(topicId, value ?? false);
                          },
                        ),
                        onTap: () async {
                          if (!mounted) return;
                          // Show full content dialog with optional code block
                                                    showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(title),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (text != null) Text(text),
                                    if (code != null) ...[
                                      const SizedBox(height: 12),
                                      const Text('Code Example:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(8),
                                        color: Colors.grey[200],
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}