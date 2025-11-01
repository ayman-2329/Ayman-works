class Course {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String difficulty;
  final String category;
  final String image;
  final List<Lesson> lessons;
  final Quiz quiz;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.category,
    required this.image,
    required this.lessons,
    required this.quiz,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      difficulty: json['difficulty'],
      category: json['category'],
      image: json['image'],
      lessons: (json['lessons'] as List)
          .map((lesson) => Lesson.fromJson(lesson))
          .toList(),
      quiz: Quiz.fromJson(json['quiz']),
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final int order;
  final LessonContent content;

  Lesson({
    required this.id,
    required this.title,
    required this.order,
    required this.content,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      order: json['order'],
      content: LessonContent.fromJson(json['content']),
    );
  }
}

class LessonContent {
  final String text;
  final List<String> keyPoints;
  final CodeExample codeExample;
  final List<Exercise> exercises;

  LessonContent({
    required this.text,
    required this.keyPoints,
    required this.codeExample,
    required this.exercises,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      text: json['text'],
      keyPoints: List<String>.from(json['keyPoints']),
      codeExample: CodeExample.fromJson(json['codeExample']),
      exercises: (json['exercises'] as List)
          .map((exercise) => Exercise.fromJson(exercise))
          .toList(),
    );
  }
}

class CodeExample {
  final String title;
  final String code;
  final String explanation;

  CodeExample({
    required this.title,
    required this.code,
    required this.explanation,
  });

  factory CodeExample.fromJson(Map<String, dynamic> json) {
    return CodeExample(
      title: json['title'],
      code: json['code'],
      explanation: json['explanation'],
    );
  }
}

class Exercise {
  final String id;
  final String title;
  final String description;
  final String solution;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.solution,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      solution: json['solution'],
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      questions: (json['questions'] as List)
          .map((question) => Question.fromJson(question))
          .toList(),
    );
  }
}

class Question {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
    );
  }
}
