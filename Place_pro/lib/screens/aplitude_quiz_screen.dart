// lib/screens/aptitude_quiz_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/aptitude_quiz.dart';

class AptitudeQuizScreen extends StatefulWidget {
  final String category;
  final String questionId;
  final Map<String, dynamic> questionData;

  const AptitudeQuizScreen({
    super.key,
    required this.category,
    required this.questionId,
    required this.questionData,
  });

  @override
  AptitudeQuizScreenState createState() => AptitudeQuizScreenState();
}

class AptitudeQuizScreenState extends State<AptitudeQuizScreen> {
  int? _selectedOption;
  bool _showResult = false;
  bool _isCorrect = false;
  Timer? _timer;
  int _secondsLeft = 300; // 5 minutes default
  bool _quizCompleted = false;
  late AptitudeQuestion _question;

  @override
  void initState() {
    super.initState();
    _initializeQuestion();
    _startTimer();
  }

  void _initializeQuestion() {
    _question = AptitudeQuestion(
      id: widget.questionId,
      question: widget.questionData['question'] ?? 'Question not found',
      options: List<String>.from(widget.questionData['options'] ?? []),
      correctAnswer: widget.questionData['correctAnswer'] ?? 0,
      explanation: widget.questionData['explanation'] ?? 'No explanation available',
      difficulty: widget.questionData['difficulty'] ?? 'Medium',
      subCategory: widget.questionData['subCategory'] ?? widget.category,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _timer?.cancel();
          _completeQuiz();
        }
      });
    });
  }

  void _checkAnswer() {
    if (_selectedOption != null) {
      setState(() {
        _isCorrect = _selectedOption == _question.correctAnswer;
        _showResult = true;
      });
    }
  }

  void _completeQuiz() {
    setState(() {
      _quizCompleted = true;
    });
    _timer?.cancel();
    _saveQuizResult();
  }


  Future<void> _saveQuizResult() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('aptitude')
          .doc(widget.questionId)
          .set({
        'questionId': widget.questionId,
        'category': widget.category,
        'isCorrect': _isCorrect,
        'selectedAnswer': _selectedOption,
        'correctAnswer': _question.correctAnswer,
        'timeTaken': 300 - _secondsLeft,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return _buildResultScreen(context);
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          '${widget.category} Question',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F9D58),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _secondsLeft <= 60 ? Colors.red : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: _secondsLeft <= 60 ? Colors.white : const Color(0xFF0F9D58),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_secondsLeft),
                  style: TextStyle(
                    color: _secondsLeft <= 60 ? Colors.white : const Color(0xFF0F9D58),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            color: const Color(0xFF0F9D58),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Single Question Practice',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        widget.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                LinearProgressIndicator(
                  value: _showResult ? 1.0 : 0.0,
                  backgroundColor: Colors.white.withAlpha(77),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F9D58).withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _question.subCategory,
                              style: const TextStyle(
                                color: Color(0xFF0F9D58),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _question.question,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Options
                  ..._question.options.asMap().entries.map((entry) {
                    int index = entry.key;
                    String option = entry.value;
                    bool isSelected = _selectedOption == index;
                    bool isCorrect = index == _question.correctAnswer;
                    
                    Color borderColor = Colors.transparent;
                    Color backgroundColor = Colors.white;
                    
                    if (_showResult) {
                      if (isCorrect) {
                        borderColor = Colors.green;
                        backgroundColor = Colors.green.withAlpha(26);
                      } else if (isSelected && !_isCorrect) {
                        borderColor = Colors.red;
                        backgroundColor = Colors.red.withAlpha(26);
                      }
                    } else if (isSelected) {
                      borderColor = const Color(0xFF0F9D58);
                      backgroundColor = const Color(0xFF0F9D58).withAlpha(26);
                    }
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: isSelected ? 4 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: borderColor, width: 2),
                        ),
                        child: InkWell(
                          onTap: _showResult ? null : () {
                            setState(() {
                              _selectedOption = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: backgroundColor,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? const Color(0xFF0F9D58)
                                        : Colors.grey[300],
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                                if (_showResult && isCorrect)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                if (_showResult && isSelected && !_isCorrect)
                                  const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 20),
                  
                  // Explanation (shown after answer)
                  if (_showResult)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isCorrect ? Colors.green.withAlpha(26) : Colors.orange.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isCorrect ? Icons.check_circle : Icons.info,
                                  color: _isCorrect ? Colors.green : Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isCorrect ? 'Correct!' : 'Explanation',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isCorrect ? Colors.green : Colors.orange,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _question.explanation,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2C3E50),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                          // Action Button
                  if (!_showResult)
                    ElevatedButton(
                      onPressed: _selectedOption == null ? null : _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F9D58),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Submit Answer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: _completeQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F9D58),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Complete Question',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Result Screen
  Widget _buildResultScreen(BuildContext context) {
    String result = _isCorrect ? 'Correct!' : 'Incorrect';
    Color resultColor = _isCorrect ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Quiz Results',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F9D58),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score Card
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0F9D58),
                      const Color(0xFF0F9D58).withAlpha(204),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.category} Question',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Result',
                    result,
                    Icons.quiz,
                    resultColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}