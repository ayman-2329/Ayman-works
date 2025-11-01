// lib/screens/admin/logical_management_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class LogicalManagementScreen extends StatefulWidget {
  const LogicalManagementScreen({super.key});

  @override
  LogicalManagementScreenState createState() => LogicalManagementScreenState();
}

class LogicalManagementScreenState extends State<LogicalManagementScreen> {
  final List<String> categories = ['Puzzles', 'Pattern Problems', 'Venn Diagrams'];
  int _selectedCategoryIndex = 0;
  
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _answerController = TextEditingController();
  final _explanationController = TextEditingController();
  String _imageUrl = '';
  bool _isLoading = false;
  bool _isAdding = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _answerController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  Future<void> _uploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    
    if (result != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        PlatformFile file = result.files.first;
        String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        
        // Upload to Firebase Storage
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('logical')
            .child(categories[_selectedCategoryIndex].toLowerCase().replaceAll(' ', '_'))
            .child(fileName);
        
        UploadTask uploadTask = storageRef.putData(file.bytes!);
        TaskSnapshot taskSnapshot = await uploadTask;
        
        // Get download URL
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        
        setState(() {
          _imageUrl = downloadUrl;
          _isLoading = false;
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
  }

  Future<void> _addProblem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        Map<String, dynamic> problemData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'answer': _answerController.text.trim(),
          'explanation': _explanationController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        if (_imageUrl.isNotEmpty) {
          problemData['imageUrl'] = _imageUrl;
        }
        
        await FirebaseFirestore.instance
            .collection('logical')
            .doc(categories[_selectedCategoryIndex].toLowerCase().replaceAll(' ', '_'))
            .collection('problems')
            .add(problemData);
        
        _clearForm();
        setState(() {
          _isAdding = false;
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Problem added successfully')),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding problem: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _answerController.clear();
    _explanationController.clear();
    _imageUrl = '';
  }

  Future<void> _deleteProblem(String category, String problemId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Problem'),
        content: const Text('Are you sure you want to delete this problem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              setState(() {
                _isLoading = true;
              });

              try {
                await FirebaseFirestore.instance
                    .collection('logical')
                    .doc(category.toLowerCase().replaceAll(' ', '_'))
                    .collection('problems')
                    .doc(problemId)
                    .delete();

                if (!mounted) return;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Problem deleted successfully')),
                  );
                  nav.pop();
                }
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting problem: $e')),
                  );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Logical Problems'),
        actions: [
          IconButton(
            icon: Icon(_isAdding ? Icons.cancel : Icons.add),
            onPressed: () {
              setState(() {
                _isAdding = !_isAdding;
                if (!_isAdding) {
                  _clearForm();
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
                // Category Tabs
                Container(
                  color: Colors.blue[50],
                  child: Row(
                    children: List.generate(
                      categories.length,
                      (index) => Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _selectedCategoryIndex == index
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: Text(
                              categories[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedCategoryIndex == index
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Add Problem Form
                if (_isAdding) _buildAddProblemForm(),
                
                // Problems List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('logical')
                        .doc(categories[_selectedCategoryIndex].toLowerCase().replaceAll(' ', '_'))
                        .collection('problems')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No problems available'));
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var problem = snapshot.data!.docs[index];
                          var problemData = problem.data() as Map<String, dynamic>;
                          String problemId = problem.id;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                problemData['title'] ?? 'Problem Title',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                problemData['description'] ?? 'Problem description',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteProblem(
                                  categories[_selectedCategoryIndex],
                                  problemId,
                                ),
                              ),
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

  Widget _buildAddProblemForm() {
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add New Problem',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Problem Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter problem title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Problem Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter problem description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _imageUrl.isEmpty ? 'No image selected' : 'Image selected',
                        style: TextStyle(
                          color: _imageUrl.isEmpty ? Colors.grey : Colors.green,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.upload_file),
                      onPressed: _uploadImage,
                    ),
                  ],
                ),
                if (_imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.network(
                      _imageUrl,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _answerController,
                  decoration: const InputDecoration(
                    labelText: 'Answer',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter answer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _explanationController,
                  decoration: const InputDecoration(
                    labelText: 'Explanation (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addProblem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add Problem'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}