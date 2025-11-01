import 'package:flutter/material.dart';
import '../data/aptitude_quiz_data.dart';
import 'aplitude_quiz_screen.dart';

class AptitudeQuizSelectionScreen extends StatefulWidget {
  const AptitudeQuizSelectionScreen({super.key});

  @override
  AptitudeQuizSelectionScreenState createState() => AptitudeQuizSelectionScreenState();
}

class AptitudeQuizSelectionScreenState extends State<AptitudeQuizSelectionScreen> with TickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  late TabController _tabController;
  
  final List<String> categories = [
    'Quantitative',
    'Logical',
    'Verbal',
    'Data Interpretation',
    'Programming'
  ];

  final Map<String, IconData> categoryIcons = {
    'Quantitative': Icons.calculate,
    'Logical': Icons.psychology,
    'Verbal': Icons.text_fields,
    'Data Interpretation': Icons.bar_chart,
    'Programming': Icons.code,
  };

  final Map<String, Color> categoryColors = {
    'Quantitative': const Color(0xFF3498DB),
    'Logical': const Color(0xFF9B59B6),
    'Verbal': const Color(0xFFE74C3C),
    'Data Interpretation': const Color(0xFFF39C12),
    'Programming': const Color(0xFF1ABC9C),
  };

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  categoryColors[categories[_selectedCategoryIndex]]!,
                  categoryColors[categories[_selectedCategoryIndex]]!.withValues(alpha: 0.8 * 255),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.quiz,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Aptitude Tests',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: const BoxDecoration(
                            color: Color(0x33FFFFFF), // 20% white
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.star, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Pro',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Stats Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Tests', '25+', Icons.quiz),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard('Categories', '5', Icons.category),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard('Difficulty', 'All', Icons.trending_up),
                        ),
                      ],
                    ),
                  ),
                  
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  
                  // Category Tabs
                  Container(
                    height: 50,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.7 * 255),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      tabs: categories.map((category) => Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(categoryIcons[category], size: 18),
                            const SizedBox(width: 8),
                            Text(category),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content Section
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) => _buildCategoryContent(category)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15 * 255),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3 * 255)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9 * 255),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(String category) {
    final quizzes = AptitudeQuizData.getAllQuizzes()
        .where((quiz) => quiz.category.toLowerCase() == category.toLowerCase())
        .toList();

    return Column(
      children: [
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
                    categoryColors[category]!,
                    categoryColors[category]!.withValues(alpha: 0.8 * 255),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  if (quizzes.isNotEmpty && quizzes.first.questions.isNotEmpty) {
                    final firstQuestion = quizzes.first.questions.first;
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AptitudeQuizScreen(
                          category: category,
                          questionId: firstQuestion.id,
                          questionData: {
                            'question': firstQuestion.question,
                            'options': firstQuestion.options,
                            'correctAnswer': firstQuestion.correctAnswer,
                            'explanation': firstQuestion.explanation,
                            'difficulty': firstQuestion.difficulty,
                            'subCategory': firstQuestion.subCategory,
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
                          categoryIcons[category],
                          color: categoryColors[category],
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$category Challenge',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Master ${quizzes.length} tests in this category',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9 * 255),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2 * 255),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Quiz List
        Expanded(
          child: quizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        categoryIcons[category],
                        size: 64,
                        color: Colors.grey.withValues(alpha: 0.5 * 255),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Coming Soon!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$category tests will be available soon.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          if (quiz.questions.isNotEmpty) {
                            final firstQuestion = quiz.questions.first;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AptitudeQuizScreen(
                                  category: category,
                                  questionId: firstQuestion.id,
                                  questionData: {
                                    'question': firstQuestion.question,
                                    'options': List<String>.from(firstQuestion.options),
                                    'correctAnswer': firstQuestion.correctAnswer,
                                    'explanation': firstQuestion.explanation,
                                    'difficulty': firstQuestion.difficulty,
                                    'subCategory': firstQuestion.subCategory,
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                categoryColors[category]!.withValues(alpha: 0.1 * 255),
                                categoryColors[category]!.withValues(alpha: 0.05 * 255),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: categoryColors[category]!.withValues(alpha: 0.2 * 255),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      categoryIcons[category],
                                      color: categoryColors[category],
                                      size: 20,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor(quiz.questions.isNotEmpty ? quiz.questions.first.difficulty : 'Medium').withValues(alpha: 0.2 * 255),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      quiz.questions.isNotEmpty ? quiz.questions.first.difficulty : 'Medium',
                                      style: TextStyle(
                                        color: _getDifficultyColor(quiz.questions.isNotEmpty ? quiz.questions.first.difficulty : 'Medium'),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                quiz.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.quiz_outlined, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${quiz.questions.length} Qs',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.timer_outlined, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${quiz.questions.length * 2} min',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
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
