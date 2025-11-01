import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../../config/mongodb_config.dart';

class CoursesManagementMongoDBScreen extends StatefulWidget {
  const CoursesManagementMongoDBScreen({super.key});

  @override
  State<CoursesManagementMongoDBScreen> createState() => CoursesManagementMongoDBScreenState();
}

class CoursesManagementMongoDBScreenState extends State<CoursesManagementMongoDBScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }
  
  // Fetch all courses from MongoDB
  Future<void> _fetchCourses() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${MongoDBConfig.baseUrl}${MongoDBConfig.coursesEndpoint}'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _courses = data.map((course) => {
            'id': course['_id'] ?? course['id'],
            'title': course['title'] ?? '',
            'description': course['description'] ?? '',
            'duration': course['duration'] ?? '',
            'instructor': course['instructor'] ?? {},
            'topics': course['topics'] ?? [],
            'enrolledStudents': course['enrolledStudents'] ?? [],
          }).toList();
        });
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error fetching courses: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Create a new course
  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final courseData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'duration': _durationController.text.trim(),
        'topics': [],
        'enrolledStudents': [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      final response = await http.post(
        Uri.parse('${MongoDBConfig.baseUrl}${MongoDBConfig.coursesEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(courseData),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final newCourse = json.decode(response.body);
        setState(() {
          _courses.add({
            'id': newCourse['_id'] ?? newCourse['id'],
            'title': newCourse['title'],
            'description': newCourse['description'],
            'duration': newCourse['duration'],
            'topics': newCourse['topics'] ?? [],
            'enrolledStudents': newCourse['enrolledStudents'] ?? [],
          });
          _clearForm();
        });
        _showSnackBar('Course created successfully');
      } else {
        throw Exception('Failed to create course: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error creating course: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Update an existing course
  Future<void> _updateCourse(String courseId) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final courseData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'duration': _durationController.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      final response = await http.patch(
        Uri.parse('${MongoDBConfig.baseUrl}${MongoDBConfig.coursesEndpoint}/$courseId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(courseData),
      );
      
      if (response.statusCode == 200) {
        final updatedCourse = json.decode(response.body);
        setState(() {
          final index = _courses.indexWhere((c) => c['id'] == courseId);
          if (index != -1) {
            _courses[index] = {
              ..._courses[index],
              ...updatedCourse,
            };
          }
          _clearForm();
        });
        _showSnackBar('Course updated successfully');
      } else {
        throw Exception('Failed to update course: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error updating course: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Delete a course
  Future<void> _deleteCourse(String courseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this course? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() => _isLoading = true);
    try {
      final response = await http.delete(
        Uri.parse('${MongoDBConfig.baseUrl}${MongoDBConfig.coursesEndpoint}/$courseId'),
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _courses.removeWhere((c) => c['id'] == courseId);
        });
        _showSnackBar('Course deleted successfully');
      } else {
        throw Exception('Failed to delete course: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error deleting course: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Import course from JSON
  Future<void> _importCourseFromJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      
      if (result == null) return;
      
      final bytes = result.files.first.bytes;
      if (bytes == null) {
        throw Exception('Could not read JSON file');
      }
      
      final jsonStr = utf8.decode(bytes);
      final parsed = json.decode(jsonStr);
      
      if (parsed is! Map<String, dynamic>) {
        throw Exception('Invalid JSON format');
      }
      
      setState(() => _isLoading = true);
      
      // Create course with imported data
      final courseData = {
        'title': parsed['title'] ?? 'Imported Course',
        'description': parsed['description'] ?? '',
        'duration': parsed['duration'] ?? '',
        'topics': parsed['topics'] ?? [],
        'enrolledStudents': [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      final response = await http.post(
        Uri.parse('${MongoDBConfig.baseUrl}${MongoDBConfig.coursesEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(courseData),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        _fetchCourses(); // Refresh the list
        _showSnackBar('Course imported successfully');
      } else {
        throw Exception('Failed to import course: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error importing course: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _durationController.clear();
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }
  
  void _showAddCourseDialog() {
    _clearForm();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Course Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 2 hours, 3 days',
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createCourse();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
  
  void _showEditCourseDialog(Map<String, dynamic> course) {
    _titleController.text = course['title'] ?? '';
    _descriptionController.text = course['description'] ?? '';
    _durationController.text = course['duration'] ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Course'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Course Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateCourse(course['id']);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MongoDB Course Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import from JSON',
            onPressed: _importCourseFromJson,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Course',
            onPressed: _showAddCourseDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No courses found', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showAddCourseDialog,
                        child: const Text('Add Your First Course'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchCourses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: Text(
                            course['title'] ?? 'Untitled Course',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(course['description'] ?? ''),
                              const SizedBox(height: 4),
                              Text(
                                'Duration: ${course['duration'] ?? 'N/A'}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'Topics: ${(course['topics'] as List).length}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'Enrolled: ${(course['enrolledStudents'] as List).length}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditCourseDialog(course),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCourse(course['id']),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Topics:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if ((course['topics'] as List).isEmpty)
                                    const Text('No topics added yet')
                                  else
                                    ...((course['topics'] as List).map((topic) => 
                                      ListTile(
                                        leading: const Icon(Icons.topic, size: 20),
                                        title: Text(topic['title'] ?? 'Untitled Topic'),
                                        subtitle: Text('Duration: ${topic['duration'] ?? 'N/A'} minutes'),
                                      )
                                    )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
