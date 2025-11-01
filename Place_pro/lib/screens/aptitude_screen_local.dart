// lib/screens/aptitude_screen_local.dart
import 'package:flutter/material.dart';
import 'package:placepro/screens/aplitude_quiz_screen.dart';
import '../data/aptitude_quiz_data.dart';
import '../models/aptitude_quiz.dart';

class AptitudeScreenLocal extends StatefulWidget {
  const AptitudeScreenLocal({super.key});

  @override
  AptitudeScreenLocalState createState() => AptitudeScreenLocalState();
}

class AptitudeScreenLocalState extends State<AptitudeScreenLocal> {
  final List<String> categories = ['Quantitative', 'Verbal', 'Reasoning'];
  int _selectedCategoryIndex = 0;
  List<AptitudeQuiz> allQuizzes = [];

  @override
  void initState() {
    super.initState();
    allQuizzes = AptitudeQuizData.getAllQuizzes();
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
    return Column(
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
        
        // Questions List
        Expanded(
          child: Builder(
            builder: (context) {
              final questions = _getQuestionsForCategory(categories[_selectedCategoryIndex]);
              
              if (questions.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No questions available for this category',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            question.question,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              question.subCategory,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () {
                        // Convert AptitudeQuestion to the format expected by AptitudeQuizScreen
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
                              category: categories[_selectedCategoryIndex],
                              questionId: question.id,
                              questionData: questionData,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
