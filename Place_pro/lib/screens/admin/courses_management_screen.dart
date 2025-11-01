// lib/screens/admin/courses_management_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class CoursesManagementScreen extends StatefulWidget {
  const CoursesManagementScreen({super.key});

  @override
  CoursesManagementScreenState createState() => CoursesManagementScreenState();
}

class CoursesManagementScreenState extends State<CoursesManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _trainerController = TextEditingController();
  final _durationController = TextEditingController();
  final _topicTitleController = TextEditingController();
  final _topicUrlController = TextEditingController();
  String _topicType = 'video';
  bool _isLoading = false;
  bool _isAddingCourse = false;
  bool _isAddingTopic = false;
  String? _selectedCourseId;

  @override
  void dispose() {
    _titleController.dispose();
    _trainerController.dispose();
    _durationController.dispose();
    _topicTitleController.dispose();
    _topicUrlController.dispose();
    super.dispose();
  }

  Future<void> _addCourse() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        DocumentReference courseRef = await FirebaseFirestore.instance.collection('courses').add({
          'title': _titleController.text.trim(),
          'trainer': _trainerController.text.trim(),
          'duration': _durationController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        _clearCourseForm();
        setState(() {
          _isAddingCourse = false;
          _selectedCourseId = courseRef.id;
          _isAddingTopic = true;
        });
        
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Course added successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error adding course: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _clearCourseForm() {
    _titleController.clear();
    _trainerController.clear();
    _durationController.clear();
  }

  Future<void> _addTopic() async {
    if (_formKey.currentState!.validate() && _selectedCourseId != null) {
      setState(() {
        _isLoading = true;
      });
      
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        // Get current count of topics to set order
        QuerySnapshot topicsSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(_selectedCourseId)
            .collection('topics')
            .get();
        
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(_selectedCourseId)
            .collection('topics')
            .add({
          'title': _topicTitleController.text.trim(),
          'url': _topicUrlController.text.trim(),
          'type': _topicType,
          'order': topicsSnapshot.docs.length,
        });
        
        _clearTopicForm();
        setState(() {
          _isAddingTopic = false;
        });
        
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Topic added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error adding topic: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _clearTopicForm() {
    _topicTitleController.clear();
    _topicUrlController.clear();
    _topicType = 'video';
  }

  Future<void> _deleteCourse(String courseId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course and all its topics?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navContext = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              navContext.pop();

              setState(() {
                _isLoading = true;
              });
              
              try {
                // Delete all topics first
                QuerySnapshot topicsSnapshot = await FirebaseFirestore.instance
                    .collection('courses')
                    .doc(courseId)
                    .collection('topics')
                    .get();
                
                for (var doc in topicsSnapshot.docs) {
                  await doc.reference.delete();
                }
                
                // Delete the course
                await FirebaseFirestore.instance
                    .collection('courses')
                    .doc(courseId)
                    .delete();
                
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Course deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error deleting course: $e')),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'mp4', 'avi', 'mkv'],
    );
    
    if (result != null) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        PlatformFile file = result.files.first;
        String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        
        // Upload to Firebase Storage
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('courses')
            .child(_selectedCourseId!)
            .child(fileName);
        
        UploadTask uploadTask = storageRef.putData(file.bytes!);
        TaskSnapshot taskSnapshot = await uploadTask;
        
        // Get download URL
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        
        if (mounted) {
          setState(() {
            _topicUrlController.text = downloadUrl;
            _topicType = file.extension == 'pdf' ? 'pdf' : 'video';
            _isLoading = false;
          });
        }
        
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('File uploaded successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error uploading file: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Courses'),
        actions: [
          IconButton(
            icon: Icon(_isAddingCourse ? Icons.cancel : Icons.add),
            onPressed: () {
              setState(() {
                _isAddingCourse = !_isAddingCourse;
                _isAddingTopic = false;
                if (!_isAddingCourse) {
                  _clearCourseForm();
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_isAddingCourse) _buildAddCourseForm(),
                if (_isAddingTopic) _buildAddTopicForm(),
                const Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('courses')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No courses available'));
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var course = snapshot.data!.docs[index];
                          var courseData = course.data() as Map<String, dynamic>;
                          String courseId = course.id;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                courseData['title'] ?? 'Course Title',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Trainer: ${courseData['trainer'] ?? 'N/A'}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.green),
                                    onPressed: () {
                                      setState(() {
                                        _selectedCourseId = courseId;
                                        _isAddingTopic = true;
                                        _isAddingCourse = false;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteCourse(courseId),
                                  ),
                                ],
                              ),
                              children: [
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('courses')
                                      .doc(courseId)
                                      .collection('topics')
                                      .orderBy('order')
                                      .snapshots(),
                                  builder: (context, topicsSnapshot) {
                                    if (topicsSnapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    
                                    if (!topicsSnapshot.hasData || topicsSnapshot.data!.docs.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text('No topics available'),
                                      );
                                    }
                                    
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: topicsSnapshot.data!.docs.length,
                                      itemBuilder: (context, topicIndex) {
                                        var topic = topicsSnapshot.data!.docs[topicIndex];
                                        var topicData = topic.data() as Map<String, dynamic>;
                                        String topicId = topic.id;
                                        
                                        return ListTile(
                                          leading: Icon(
                                            topicData['type'] == 'video' ? Icons.play_circle : Icons.picture_as_pdf,
                                            color: topicData['type'] == 'video' ? Colors.blue : Colors.red,
                                          ),
                                          title: Text(topicData['title'] ?? 'Topic Title'),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () async {
                                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                                              await FirebaseFirestore.instance
                                                  .collection('courses')
                                                  .doc(courseId)
                                                  .collection('topics')
                                                  .doc(topicId)
                                                  .delete();
                                              if (!mounted) return;
                                              scaffoldMessenger.showSnackBar(
                                                const SnackBar(content: Text('Topic deleted')),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
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

  Widget _buildAddCourseForm() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Course',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Course Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _trainerController,
                decoration: const InputDecoration(
                  labelText: 'Trainer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter trainer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 2 hours, 3 days',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addCourse,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddTopicForm() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add New Topic',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        _isAddingTopic = false;
                        _clearTopicForm();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _topicTitleController,
                decoration: const InputDecoration(
                  labelText: 'Topic Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter topic title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _topicType,
                decoration: const InputDecoration(
                  labelText: 'Topic Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'video', child: Text('Video')),
                  DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                ],
                onChanged: (value) {
                  setState(() {
                    _topicType = value ?? 'video';
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _topicUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter URL or upload a file';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.upload_file),
                    onPressed: _uploadFile,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addTopic,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add Topic'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}