// lib/screens/logical_reasoning_quiz_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/logical_reasoning_data.dart';
import '../models/aptitude_quiz.dart';

class LogicalReasoningQuizScreen extends StatefulWidget {
  final Map<String, dynamic>? singleQuestion;
  
  const LogicalReasoningQuizScreen({super.key, this.singleQuestion});

  @override
  LogicalReasoningQuizScreenState createState() => LogicalReasoningQuizScreenState();
}

class LogicalReasoningQuizScreenState extends State<LogicalReasoningQuizScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOption;
  bool _showResult = false;
  bool _isCorrect = false;
  Timer? _timer;
  int _secondsLeft = 45;
  Map<int, int> _userAnswers = {};
  bool _quizCompleted = false;
  List<AptitudeQuestion> _questions = [];
  int _streak = 0;
  int _maxStreak = 0;
  
  late AnimationController _progressController;
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );

    _cardController.forward();
  }

  void _loadQuestions() {
    if (widget.singleQuestion != null) {
      // Single question mode - convert Map to AptitudeQuestion
      _questions = [AptitudeQuestion(
        id: widget.singleQuestion!['id'] ?? 'single',
        question: widget.singleQuestion!['question'],
        options: List<String>.from(widget.singleQuestion!['options']),
        correctAnswer: widget.singleQuestion!['correctAnswer'],
        explanation: widget.singleQuestion!['explanation'],
        difficulty: widget.singleQuestion!['difficulty'],
        subCategory: widget.singleQuestion!['subCategory'],
      )];
    } else {
      // Full quiz mode - get all logical reasoning questions and shuffle them
      final allQuestions = LogicalReasoningData.getAllQuestions();
      allQuestions.shuffle();
      
      _questions = allQuestions;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _timer?.cancel();
          _timeUp();
        }
      });
    });
  }

  void _timeUp() {
    setState(() {
      _showResult = true;
      _isCorrect = false;
      _streak = 0;
    });
  }

  void _checkAnswer() {
    if (_selectedOption != null) {
      final currentQuestion = _questions[_currentQuestionIndex];
      setState(() {
        _isCorrect = _selectedOption == currentQuestion.correctAnswer;
        _showResult = true;
        _userAnswers[_currentQuestionIndex] = _selectedOption!;
        if (_isCorrect) {
          _score++;
          _streak++;
          _maxStreak = max(_maxStreak, _streak);
        } else {
          _streak = 0;
        }
      });
      _timer?.cancel();
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
        _showResult = false;
        _isCorrect = false;
        _secondsLeft = 45;
      });
      _cardController.reset();
      _cardController.forward();
      _startTimer();
    } else {
      _completeQuiz();
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
          .collection('logical_reasoning')
          .doc('session_${DateTime.now().millisecondsSinceEpoch}')
          .set({
        'score': _score,
        'totalQuestions': _questions.length,
        'maxStreak': _maxStreak,
        'percentage': (_score / _questions.length) * 100,
        'timestamp': FieldValue.serverTimestamp(),
        'answers': _userAnswers,
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return _buildResultScreen(context);
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Logical Reasoning'),
          backgroundColor: const Color(0xFF6A4C93),
        ),
        body: const Center(
          child: Text('No questions available'),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Logical Reasoning Challenge',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6A4C93),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _secondsLeft <= 10 ? Colors.red : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: _secondsLeft <= 10 ? Colors.white : const Color(0xFF6A4C93),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_secondsLeft),
                  style: TextStyle(
                    color: _secondsLeft <= 10 ? Colors.white : const Color(0xFF6A4C93),
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
          // Enhanced Progress Section
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A4C93), Color(0xFF8E44AD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            currentQuestion.subCategory,
                            style: TextStyle(
                              color: Colors.white.withAlpha(204),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Score: $_score',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (_streak > 1)
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Streak: $_streak',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: Colors.white.withAlpha(77),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _cardAnimation.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Enhanced Question Card
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.grey.shade50,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getDifficultyColor(currentQuestion.difficulty).withAlpha(26),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _getDifficultyColor(currentQuestion.difficulty),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          currentQuestion.difficulty,
                                          style: TextStyle(
                                            color: _getDifficultyColor(currentQuestion.difficulty),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6A4C93).withAlpha(77),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          currentQuestion.subCategory,
                                          style: const TextStyle(
                                            color: Color(0xFF6A4C93),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    currentQuestion.question,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Enhanced Options
                        ...currentQuestion.options.asMap().entries.map((entry) {
                          int index = entry.key;
                          String option = entry.value;
                          bool isSelected = _selectedOption == index;
                          bool isCorrect = index == currentQuestion.correctAnswer;
                          
                          Color borderColor = Colors.transparent;
                          Color backgroundColor = Colors.white;
                          IconData? iconData;
                          
                          if (_showResult) {
                            if (isCorrect) {
                              borderColor = Colors.green;
                              backgroundColor = Colors.green.withAlpha(26);
                              iconData = Icons.check_circle;
                            } else if (isSelected && !_isCorrect) {
                              borderColor = Colors.red;
                              backgroundColor = Colors.red.withAlpha(26);
                              iconData = Icons.cancel;
                            }
                          } else if (isSelected) {
                            borderColor = const Color(0xFF6A4C93);
                            backgroundColor = const Color(0xFF6A4C93).withAlpha(26);
                          }
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Card(
                              elevation: isSelected ? 8 : 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: borderColor, width: 2),
                              ),
                              child: InkWell(
                                onTap: _showResult ? null : () {
                                  setState(() {
                                    _selectedOption = index;
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? const Color(0xFF6A4C93)
                                              : Colors.grey[200],
                                          boxShadow: isSelected ? [
                                            BoxShadow(
                                              color: const Color(0xFF6A4C93).withAlpha(77),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ] : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + index),
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
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
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      if (iconData != null)
                                        Icon(
                                          iconData,
                                          color: isCorrect ? Colors.green : Colors.red,
                                          size: 28,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        
                        const SizedBox(height: 20),
                        
                        // Enhanced Explanation
                        if (_showResult)
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _isCorrect ? Colors.green.withAlpha(26) : Colors.orange.withAlpha(26),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _isCorrect ? Colors.green : Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _isCorrect ? Icons.check : Icons.lightbulb,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _isCorrect ? 'Correct!' : 'Explanation',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _isCorrect ? Colors.green : Colors.orange,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    currentQuestion.explanation,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF2C3E50),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 32),
                        
                        // Enhanced Action Button
                        if (!_showResult)
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: _selectedOption == null ? null : const LinearGradient(
                                colors: [Color(0xFF6A4C93), Color(0xFF8E44AD)],
                              ),
                              boxShadow: _selectedOption == null ? null : [
                                BoxShadow(
                                  color: const Color(0xFF6A4C93).withAlpha(77),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _selectedOption == null ? null : _checkAnswer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Submit Answer',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A4C93), Color(0xFF8E44AD)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6A4C93).withAlpha(77),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _nextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                _currentQuestionIndex < _questions.length - 1
                                    ? 'Next Question'
                                    : 'Complete Quiz',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context) {
    double percentage = (_score / _questions.length) * 100;
    String grade = percentage >= 90 ? 'A+' : 
                   percentage >= 80 ? 'A' : 
                   percentage >= 70 ? 'B' : 
                   percentage >= 60 ? 'C' : 
                   percentage >= 50 ? 'D' : 'F';
    
    Color gradeColor = percentage >= 70 ? Colors.green : 
                       percentage >= 50 ? Colors.orange : Colors.red;

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
        backgroundColor: const Color(0xFF6A4C93),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Enhanced Score Card
            Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6A4C93),
                      Color(0xFF8E44AD),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Color(0xFF6A4C93),
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Logical Reasoning Complete!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You answered ${_questions.length} questions',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Enhanced Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  'Score',
                  '$_score/${_questions.length}',
                  Icons.quiz,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Percentage',
                  '${percentage.toStringAsFixed(1)}%',
                  Icons.percent,
                  gradeColor,
                ),
                _buildStatCard(
                  'Grade',
                  grade,
                  Icons.grade,
                  gradeColor,
                ),
                _buildStatCard(
                  'Max Streak',
                  '$_maxStreak',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A4C93), Color(0xFF8E44AD)],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Back to Questions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF6A4C93), width: 2),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex = 0;
                          _score = 0;
                          _selectedOption = null;
                          _showResult = false;
                          _isCorrect = false;
                          _userAnswers = {};
                          _quizCompleted = false;
                          _streak = 0;
                          _maxStreak = 0;
                          _secondsLeft = 45;
                        });
                        _questions.shuffle();
                        _cardController.reset();
                        _progressController.reset();
                        _startTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A4C93),
                        ),
                      ),
                    ),
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withAlpha(26),
              color.withAlpha(25),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
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
