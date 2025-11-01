import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/course.dart';

class CourseService {
  static final CourseService _instance = CourseService._internal();
  factory CourseService() => _instance;
  CourseService._internal();

  List<Course> _courses = [];
  List<Course> get courses => _courses;

  Future<void> loadCourses() async {
    try {
      // Load Python course from JSON
      final String pythonJson = await rootBundle.loadString('assets/data/python_basics.json');
      final pythonData = json.decode(pythonJson);
      final pythonCourse = Course.fromJson(pythonData['courses']['python_basics']);
      
      _courses = [pythonCourse];
    } catch (e) {
      debugPrint('Error loading courses: $e');
      // Fallback to mock data if JSON loading fails
      _courses = _getMockCourses();
    }
  }

  List<Course> _getMockCourses() {
    return [
      Course(
        id: 'python_basics',
        title: 'Python Programming Fundamentals',
        description: 'A comprehensive introduction to Python programming for beginners',
        duration: '6 weeks',
        difficulty: 'Beginner',
        category: 'programming',
        image: 'https://example.com/images/python_course.jpg',
        lessons: [
          Lesson(
            id: 'lesson1',
            title: 'Introduction to Python',
            order: 1,
            content: LessonContent(
              text: 'Python is a high-level, interpreted programming language known for its simplicity and readability.',
              keyPoints: [
                'Python is interpreted and high-level',
                'Emphasizes code readability',
                'Supports multiple programming paradigms'
              ],
              codeExample: CodeExample(
                title: 'Your First Python Program',
                code: 'print("Hello, World!")\nprint(2 + 3)',
                explanation: 'Basic Python syntax and print function',
              ),
              exercises: [
                Exercise(
                  id: 'ex1',
                  title: 'Print Your Name',
                  description: 'Write a Python program that prints your name',
                  solution: 'print("Your Name")',
                ),
              ],
            ),
          ),
        ],
        quiz: Quiz(
          id: 'python_basics_quiz',
          title: 'Python Basics Quiz',
          questions: [
            Question(
              id: 'q1',
              question: 'Which of the following is the correct way to create a variable in Python?',
              options: ['name = value', 'var name = value', 'variable name = value'],
              correctAnswer: 'name = value',
              explanation: 'In Python, variables are created by simply assigning a value to them',
            ),
          ],
        ),
      ),
    ];
  }

  List<Course> getCoursesByCategory(String category) {
    return _courses.where((course) => course.category == category).toList();
  }

  List<Course> getCoursesByDifficulty(String difficulty) {
    return _courses.where((course) => course.difficulty == difficulty).toList();
  }

  Course? getCourseById(String id) {
    return _courses.firstWhere((course) => course.id == id);
  }
}
