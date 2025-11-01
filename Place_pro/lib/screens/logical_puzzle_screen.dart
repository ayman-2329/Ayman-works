// lib/screens/logical_puzzle_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogicalPuzzleScreen extends StatefulWidget {
  final String category;
  final String problemId;
  final Map<String, dynamic> problemData;

  const LogicalPuzzleScreen({
    super.key,
    required this.category,
    required this.problemId,
    required this.problemData,
  });

  @override
  LogicalPuzzleScreenState createState() => LogicalPuzzleScreenState();
}

class LogicalPuzzleScreenState extends State<LogicalPuzzleScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _showResult = false;
  bool _isCorrect = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    String userAnswer = _answerController.text.trim().toLowerCase();
    String correctAnswer = widget.problemData['answer'].toString().toLowerCase();
    
    setState(() {
      _isCorrect = userAnswer == correctAnswer;
      _showResult = true;
    });
    
    // Save result to Firestore
    _savePuzzleResult();
  }

  Future<void> _savePuzzleResult() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('logical')
          .doc(widget.problemId)
          .set({
        'category': widget.category,
        'isCorrect': _isCorrect,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void _nextProblem() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Problem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Problem Title
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.problemData['title'] ?? 'Problem Title',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Problem Description/Image
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Problem Description
                        Text(
                          widget.problemData['description'] ?? 'Problem description',
                          style: const TextStyle(fontSize: 16),
                        ),
                        
                        // Problem Image (if available)
                        if (widget.problemData['imageUrl'] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Image.network(widget.problemData['imageUrl']),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Answer Input
            if (!_showResult)
              Column(
                children: [
                  TextField(
                    controller: _answerController,
                    decoration: const InputDecoration(
                      labelText: 'Your Answer',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your answer here',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _answerController.text.trim().isEmpty ? null : _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Submit Answer'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCorrect ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isCorrect ? Icons.check_circle : Icons.cancel,
                          color: _isCorrect ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _isCorrect
                                ? 'Correct! Well done.'
                                : 'Incorrect. The right answer is: ${widget.problemData['answer']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isCorrect ? Colors.green[800] : Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Solution/Explanation
                  if (widget.problemData['explanation'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Explanation:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.problemData['explanation'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _nextProblem,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Next Problem'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}