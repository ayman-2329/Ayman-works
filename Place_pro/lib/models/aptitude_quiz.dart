class AptitudeQuiz {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<AptitudeQuestion> questions;
  final int timeLimit; // in minutes
  final String difficulty;

  AptitudeQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.questions,
    required this.timeLimit,
    required this.difficulty,
  });

  factory AptitudeQuiz.fromJson(Map<String, dynamic> json) {
    return AptitudeQuiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      questions: (json['questions'] as List)
          .map((q) => AptitudeQuestion.fromJson(q))
          .toList(),
      timeLimit: json['timeLimit'],
      difficulty: json['difficulty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'questions': questions.map((q) => q.toJson()).toList(),
      'timeLimit': timeLimit,
      'difficulty': difficulty,
    };
  }
}

class AptitudeQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final String difficulty;
  final String subCategory;

  AptitudeQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    required this.subCategory,
  });

  factory AptitudeQuestion.fromJson(Map<String, dynamic> json) {
    return AptitudeQuestion(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
      difficulty: json['difficulty'],
      subCategory: json['subCategory'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty,
      'subCategory': subCategory,
    };
  }
}

class QuizResult {
  final String quizId;
  final String userId;
  final int score;
  final int totalQuestions;
  final int timeTaken; // in seconds
  final DateTime completedAt;
  final Map<String, dynamic> answers;

  QuizResult({
    required this.quizId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
    required this.completedAt,
    required this.answers,
  });

  double get percentage => (score / totalQuestions) * 100;

  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }
}
