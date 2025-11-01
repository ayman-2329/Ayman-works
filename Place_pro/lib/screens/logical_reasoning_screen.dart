// lib/screens/logical_reasoning_screen.dart
import 'package:flutter/material.dart';
import 'package:placepro/screens/logical_reasoning_quiz_screen.dart';
import '../data/logical_reasoning_data.dart';

class LogicalReasoningScreen extends StatefulWidget {
  const LogicalReasoningScreen({super.key});

  @override
  LogicalReasoningScreenState createState() => LogicalReasoningScreenState();
}

class LogicalReasoningScreenState extends State<LogicalReasoningScreen> with TickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  late TabController _tabController;
  
  final List<String> categories = [
    'Pattern Recognition',
    'Logical Sequences',
    'Analytical Reasoning',
    'Critical Thinking',
    'Spatial Reasoning',
    'Deductive Logic'
  ];

  final Map<String, IconData> categoryIcons = {
    'Pattern Recognition': Icons.pattern,
    'Logical Sequences': Icons.timeline,
    'Analytical Reasoning': Icons.analytics,
    'Critical Thinking': Icons.psychology,
    'Spatial Reasoning': Icons.view_in_ar,
    'Deductive Logic': Icons.account_tree,
  };

  final Map<String, Color> categoryColors = {
    'Pattern Recognition': const Color(0xFF6A4C93),
    'Logical Sequences': const Color(0xFF8E44AD),
    'Analytical Reasoning': const Color(0xFF3498DB),
    'Critical Thinking': const Color(0xFF2ECC71),
    'Spatial Reasoning': const Color(0xFFE74C3C),
    'Deductive Logic': const Color(0xFFF39C12),
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
                  categoryColors[categories[_selectedCategoryIndex]]!.withAlpha(204),
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
                          Icons.psychology,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Logical Reasoning',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
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
                          child: _buildStatCard('Questions', '150+', Icons.quiz),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard('Categories', '6', Icons.category),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard('Difficulty', 'All', Icons.trending_up),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Category Tabs
                  SizedBox(
                    height: 50,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withAlpha(179),
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
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(77)),
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
              color: Colors.white.withAlpha(230),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(String category) {
    // Get questions from the new logical reasoning database
    final displayQuestions = LogicalReasoningData.getQuestionsByCategory(category);

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
                    categoryColors[category]!.withAlpha(204),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LogicalReasoningQuizScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
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
                              'Master ${displayQuestions.length} questions in this category',
                              style: TextStyle(
                                color: Colors.white.withAlpha(230),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
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
        
        // Questions List
        Expanded(
          child: displayQuestions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        categoryIcons[category],
                        size: 64,
                        color: Colors.grey.withAlpha(128),
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
                        '$category questions will be available soon.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: displayQuestions.length,
                  itemBuilder: (context, index) {
                    final question = displayQuestions[index];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                              builder: (context) => LogicalReasoningQuizScreen(
                                singleQuestion: questionData,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: categoryColors[category]!.withAlpha(26),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: categoryColors[category]!,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      question.question,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
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
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.timer,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '2 min',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
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
