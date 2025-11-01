// lib/screens/aptitude_screen.dart
import 'package:flutter/material.dart';
import 'package:placepro/screens/aplitude_quiz_screen.dart';
import '../data/aptitude_quiz_data.dart';
import '../models/aptitude_quiz.dart';

class AptitudeScreen extends StatefulWidget {
  const AptitudeScreen({super.key});

  @override
  AptitudeScreenState createState() => AptitudeScreenState();
}

class AptitudeScreenState extends State<AptitudeScreen>
    with TickerProviderStateMixin {
  final List<String> categories = ['Quantitative', 'Verbal', 'Reasoning'];
  int _selectedCategoryIndex = 0;
  List<AptitudeQuiz> allQuizzes = [];
  late TabController _tabController;

  final Map<String, IconData> categoryIcons = {
    'Quantitative': Icons.calculate,
    'Verbal': Icons.text_fields,
    'Reasoning': Icons.psychology,
  };

  final Map<String, Color> categoryColors = const {
    'Quantitative': Color(0xFF2196F3),
    'Verbal': Color(0xFF4CAF50),
    'Reasoning': Color(0xFF9C27B0),
  };

  @override
  void initState() {
    super.initState();
    allQuizzes = AptitudeQuizData.getAllQuizzes();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedCategoryIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AptitudeQuestion> _getQuestionsForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'quantitative':
        return allQuizzes
            .firstWhere((quiz) => quiz.category == 'Quantitative',
                orElse: () => AptitudeQuiz(
                    id: '',
                    title: '',
                    description: '',
                    category: '',
                    questions: [],
                    timeLimit: 0,
                    difficulty: ''))
            .questions;
      case 'verbal':
        return allQuizzes
            .firstWhere((quiz) => quiz.category == 'Verbal',
                orElse: () => AptitudeQuiz(
                    id: '',
                    title: '',
                    description: '',
                    category: '',
                    questions: [],
                    timeLimit: 0,
                    difficulty: ''))
            .questions;
      case 'reasoning':
        return allQuizzes
            .firstWhere((quiz) => quiz.category == 'Logical',
                orElse: () => AptitudeQuiz(
                    id: '',
                    title: '',
                    description: '',
                    category: '',
                    questions: [],
                    timeLimit: 0,
                    difficulty: ''))
            .questions;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Section with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  categoryColors[categories[_selectedCategoryIndex]]!,
                  categoryColors[categories[_selectedCategoryIndex]]!.withAlpha(204),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          categoryIcons[categories[_selectedCategoryIndex]],
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aptitude Training',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Master ${categories[_selectedCategoryIndex]} Skills',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(230),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stats Cards Row
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Questions',
                    '${_getQuestionsForCategory(categories[_selectedCategoryIndex]).length}',
                    Icons.quiz,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Categories',
                    '${categories.length}',
                    Icons.category,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Difficulty',
                    'Mixed',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Category Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: categoryColors[categories[_selectedCategoryIndex]],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: categories.map((category) {
                return Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        categoryIcons[category],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          category,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Challenge Mode Button
          Container(
            margin: const EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColors[categories[_selectedCategoryIndex]]!,
                      categoryColors[categories[_selectedCategoryIndex]]!.withAlpha(204),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    final questions = _getQuestionsForCategory(categories[_selectedCategoryIndex]);
                    if (questions.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AptitudeQuizScreen(
                            category: categories[_selectedCategoryIndex],
                            questionId: questions.first.id,
                            questionData: {
                              'question': questions.first.question,
                              'options': questions.first.options,
                              'correctAnswer': questions.first.correctAnswer,
                              'explanation': questions.first.explanation,
                              'difficulty': questions.first.difficulty,
                              'subCategory': questions.first.subCategory,
                            },
                          ),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            categoryIcons[categories[_selectedCategoryIndex]],
                            color: categoryColors[categories[_selectedCategoryIndex]],
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Challenge Mode',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Test your ${categories[_selectedCategoryIndex]} skills!',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(230),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Questions List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                final questions = _getQuestionsForCategory(category);
                
                if (questions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          categoryIcons[category],
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No $category questions available',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          final questionData = {
                            'question': question.question,
                            'options': question.options,
                            'correctAnswer': question.correctAnswer,
                            'explanation': question.explanation,
                            'difficulty': question.difficulty,
                            'subCategory': question.subCategory,
                          };
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AptitudeQuizScreen(
                                category: category,
                                questionId: question.id,
                                questionData: questionData,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: categoryColors[category]!.withAlpha(26),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      categoryIcons[category],
                                      color: categoryColors[category],
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Question ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor(question.difficulty).withAlpha(26),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getDifficultyColor(question.difficulty),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      question.difficulty,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getDifficultyColor(question.difficulty),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                question.question,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: categoryColors[category]!.withAlpha(26),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      question.subCategory,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: categoryColors[category],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: categoryColors[category],
                                    size: 16,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
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
        return Colors.grey;
    }
  }
}