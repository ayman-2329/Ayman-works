import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AptitudeManagementScreen extends StatefulWidget {
  const AptitudeManagementScreen({super.key});

  @override
  AptitudeManagementScreenState createState() => AptitudeManagementScreenState();
}

class AptitudeManagementScreenState extends State<AptitudeManagementScreen> {
  final List<String> categories = ['Quantitative', 'Verbal', 'Reasoning'];
  int _selectedCategoryIndex = 0;
  
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(4, (index) => TextEditingController());
  int _correctAnswer = 0;
  bool _isLoading = false;
  bool _isAdding = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _addQuestion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        List<String> options = _optionControllers.map((controller) => controller.text.trim()).toList();
        await FirebaseFirestore.instance
            .collection('aptitude')
            .doc(categories[_selectedCategoryIndex].toLowerCase())
            .collection('questions')
            .add({
          'question': _questionController.text.trim(),
          'options': options,
          'correctAnswer': _correctAnswer,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        _clearForm();
        setState(() {
          _isAdding = false;
        });
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Question added successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error adding question: $e')),
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

  void _clearForm() {
    _questionController.clear();
    for (var controller in _optionControllers) {
      controller.clear();
    }
    _correctAnswer = 0;
  }

  Future<void> _deleteQuestion(String category, String questionId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
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
                await FirebaseFirestore.instance
                    .collection('aptitude')
                    .doc(category.toLowerCase())
                    .collection('questions')
                    .doc(questionId)
                    .delete();

                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Question deleted successfully')),
                );
              } catch (e) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error deleting question: $e')),
                );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Aptitude Questions'),
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
                // Add Question Form
                if (_isAdding) _buildAddQuestionForm(),
                // Questions List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('aptitude')
                        .doc(categories[_selectedCategoryIndex].toLowerCase())
                        .collection('questions')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No questions available'));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var question = snapshot.data!.docs[index];
                          var questionData = question.data() as Map<String, dynamic>;
                          String questionId = question.id;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                'Question ${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                questionData['question'] ?? 'Question text',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteQuestion(
                                  categories[_selectedCategoryIndex],
                                  questionId,
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

  Widget _buildAddQuestionForm() {
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
                'Add New Question',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter question';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Options',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Option ${String.fromCharCode(65 + index)}', // A, B, C, D
                      border: const OutlineInputBorder(),
                      suffixIcon: Radio<int>(
                        value: index,
                        groupValue: _correctAnswer,
                        onChanged: (value) {
                          setState(() {
                            _correctAnswer = value ?? 0;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter option';
                      }
                      return null;
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}