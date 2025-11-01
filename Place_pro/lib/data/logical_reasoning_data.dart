// lib/data/logical_reasoning_data.dart
import '../models/aptitude_quiz.dart';

class LogicalReasoningData {
  static List<AptitudeQuestion> getAllQuestions() {
    return [
      ...getPatternRecognitionQuestions(),
      ...getLogicalSequenceQuestions(),
      ...getAnalyticalReasoningQuestions(),
      ...getCriticalThinkingQuestions(),
      ...getSpatialReasoningQuestions(),
      ...getDeductiveLogicQuestions(),
    ];
  }

  static List<AptitudeQuestion> getPatternRecognitionQuestions() {
    return [
      AptitudeQuestion(
        id: 'pr1',
        question: 'What comes next in the series: 2, 6, 18, 54, ?',
        options: ['162', '108', '216', '324'],
        correctAnswer: 0,
        explanation: 'Each number is multiplied by 3: 2×3=6, 6×3=18, 18×3=54, 54×3=162',
        difficulty: 'Easy',
        subCategory: 'Pattern Recognition',
      ),
      AptitudeQuestion(
        id: 'pr2',
        question: 'Find the missing number: 1, 4, 9, 16, ?, 36',
        options: ['20', '25', '30', '32'],
        correctAnswer: 1,
        explanation: 'These are perfect squares: 1², 2², 3², 4², 5², 6². Missing number is 5² = 25',
        difficulty: 'Easy',
        subCategory: 'Pattern Recognition',
      ),
      AptitudeQuestion(
        id: 'pr3',
        question: 'What is the next term: A, D, G, J, ?',
        options: ['K', 'L', 'M', 'N'],
        correctAnswer: 2,
        explanation: 'Each letter moves 3 positions forward: A(+3)→D(+3)→G(+3)→J(+3)→M',
        difficulty: 'Medium',
        subCategory: 'Pattern Recognition',
      ),
      AptitudeQuestion(
        id: 'pr4',
        question: 'Complete the pattern: 3, 7, 15, 31, ?',
        options: ['47', '55', '63', '71'],
        correctAnswer: 2,
        explanation: 'Pattern: (n×2)+1. 3×2+1=7, 7×2+1=15, 15×2+1=31, 31×2+1=63',
        difficulty: 'Medium',
        subCategory: 'Pattern Recognition',
      ),
      AptitudeQuestion(
        id: 'pr5',
        question: 'Find the odd one out: 8, 27, 64, 125, 216, 343, 729',
        options: ['8', '27', '729', '343'],
        correctAnswer: 2,
        explanation: '729 = 9³, but the pattern shows cubes of consecutive numbers: 2³, 3³, 4³, 5³, 6³, 7³. 729 = 9³ breaks the sequence.',
        difficulty: 'Hard',
        subCategory: 'Pattern Recognition',
      ),
    ];
  }

  static List<AptitudeQuestion> getLogicalSequenceQuestions() {
    return [
      AptitudeQuestion(
        id: 'ls1',
        question: 'If Monday is the 1st, what day is the 15th?',
        options: ['Monday', 'Tuesday', 'Wednesday', 'Thursday'],
        correctAnswer: 0,
        explanation: 'Days repeat every 7. 15 = 2×7 + 1, so it\'s the same as day 1 = Monday',
        difficulty: 'Easy',
        subCategory: 'Logical Sequences',
      ),
      AptitudeQuestion(
        id: 'ls2',
        question: 'In a sequence: 5, 11, 23, 47, ?, what comes next?',
        options: ['71', '95', '119', '143'],
        correctAnswer: 1,
        explanation: 'Pattern: (n×2)+1. 5×2+1=11, 11×2+1=23, 23×2+1=47, 47×2+1=95',
        difficulty: 'Medium',
        subCategory: 'Logical Sequences',
      ),
      AptitudeQuestion(
        id: 'ls3',
        question: 'Complete: 1, 1, 2, 3, 5, 8, ?',
        options: ['11', '13', '15', '17'],
        correctAnswer: 1,
        explanation: 'Fibonacci sequence: each number is sum of previous two. 5+8=13',
        difficulty: 'Easy',
        subCategory: 'Logical Sequences',
      ),
      AptitudeQuestion(
        id: 'ls4',
        question: 'What comes next: Z, Y, X, W, V, ?',
        options: ['U', 'T', 'S', 'R'],
        correctAnswer: 0,
        explanation: 'Reverse alphabetical order: Z, Y, X, W, V, U',
        difficulty: 'Easy',
        subCategory: 'Logical Sequences',
      ),
      AptitudeQuestion(
        id: 'ls5',
        question: 'Find the next number: 2, 6, 12, 20, 30, ?',
        options: ['40', '42', '44', '46'],
        correctAnswer: 1,
        explanation: 'Pattern: n(n+1). 2=1×2, 6=2×3, 12=3×4, 20=4×5, 30=5×6, next=6×7=42',
        difficulty: 'Hard',
        subCategory: 'Logical Sequences',
      ),
    ];
  }

  static List<AptitudeQuestion> getAnalyticalReasoningQuestions() {
    return [
      AptitudeQuestion(
        id: 'ar1',
        question: 'If all roses are flowers and some flowers are red, which conclusion is valid?',
        options: ['All roses are red', 'Some roses are red', 'No roses are red', 'Some roses may be red'],
        correctAnswer: 3,
        explanation: 'We cannot conclude definitively about roses being red, only that some roses may be red.',
        difficulty: 'Medium',
        subCategory: 'Analytical Reasoning',
      ),
      AptitudeQuestion(
        id: 'ar2',
        question: 'A is taller than B. B is taller than C. Who is the shortest?',
        options: ['A', 'B', 'C', 'Cannot determine'],
        correctAnswer: 2,
        explanation: 'If A > B > C, then C is the shortest.',
        difficulty: 'Easy',
        subCategory: 'Analytical Reasoning',
      ),
      AptitudeQuestion(
        id: 'ar3',
        question: 'In a group of 5 people, if each person shakes hands with every other person exactly once, how many handshakes occur?',
        options: ['10', '15', '20', '25'],
        correctAnswer: 0,
        explanation: 'Formula: n(n-1)/2 = 5×4/2 = 10 handshakes',
        difficulty: 'Medium',
        subCategory: 'Analytical Reasoning',
      ),
      AptitudeQuestion(
        id: 'ar4',
        question: 'If it takes 5 machines 5 minutes to make 5 widgets, how long does it take 100 machines to make 100 widgets?',
        options: ['5 minutes', '20 minutes', '100 minutes', '500 minutes'],
        correctAnswer: 0,
        explanation: 'Each machine makes 1 widget in 5 minutes, so 100 machines make 100 widgets in 5 minutes.',
        difficulty: 'Hard',
        subCategory: 'Analytical Reasoning',
      ),
      AptitudeQuestion(
        id: 'ar5',
        question: 'Three friends have ages that are consecutive even numbers. Their total age is 48. What is the age of the youngest?',
        options: ['14', '15', '16', '18'],
        correctAnswer: 0,
        explanation: 'Let ages be n, n+2, n+4. Sum: 3n+6=48, so 3n=42, n=14',
        difficulty: 'Hard',
        subCategory: 'Analytical Reasoning',
      ),
    ];
  }

  static List<AptitudeQuestion> getCriticalThinkingQuestions() {
    return [
      AptitudeQuestion(
        id: 'ct1',
        question: 'All birds can fly. Penguins are birds. Therefore, penguins can fly. What\'s wrong with this reasoning?',
        options: ['Nothing wrong', 'False premise', 'Invalid logic', 'Circular reasoning'],
        correctAnswer: 1,
        explanation: 'The premise "All birds can fly" is false. Penguins, ostriches, and other birds cannot fly.',
        difficulty: 'Medium',
        subCategory: 'Critical Thinking',
      ),
      AptitudeQuestion(
        id: 'ct2',
        question: 'A man lives on the 20th floor. Every morning he takes the elevator down. When he comes home, he takes the elevator to the 10th floor and walks the rest. Why?',
        options: ['Exercise', 'Elevator broken', 'He\'s short', 'Saves money'],
        correctAnswer: 2,
        explanation: 'He\'s too short to reach the button for the 20th floor, but can reach the 10th floor button.',
        difficulty: 'Hard',
        subCategory: 'Critical Thinking',
      ),
      AptitudeQuestion(
        id: 'ct3',
        question: 'Which assumption is necessary for this argument: "Students who study hard get good grades, so John will get good grades"?',
        options: ['John is smart', 'John studies hard', 'John attends class', 'John likes school'],
        correctAnswer: 1,
        explanation: 'The argument assumes John studies hard to conclude he will get good grades.',
        difficulty: 'Medium',
        subCategory: 'Critical Thinking',
      ),
      AptitudeQuestion(
        id: 'ct4',
        question: 'What is the main flaw in this reasoning: "Most accidents happen at home, so it\'s safer to drive than stay home"?',
        options: ['False statistics', 'Ignores time spent', 'Wrong conclusion', 'Missing data'],
        correctAnswer: 1,
        explanation: 'It ignores that people spend much more time at home than driving, affecting the rate comparison.',
        difficulty: 'Hard',
        subCategory: 'Critical Thinking',
      ),
      AptitudeQuestion(
        id: 'ct5',
        question: 'A store owner says: "Buy 2 items and get 50% off the second item!" If items cost \$10 each, what\'s the real discount?',
        options: ['50%', '25%', '33%', '20%'],
        correctAnswer: 1,
        explanation: 'Total cost: \$15 instead of \$20. Discount: \$5/\$20 = 25% off total purchase.',
        difficulty: 'Medium',
        subCategory: 'Critical Thinking',
      ),
    ];
  }

  static List<AptitudeQuestion> getSpatialReasoningQuestions() {
    return [
      AptitudeQuestion(
        id: 'sr1',
        question: 'A cube is painted red on all faces, then cut into 27 smaller cubes. How many small cubes have exactly 2 red faces?',
        options: ['8', '12', '6', '0'],
        correctAnswer: 1,
        explanation: 'Edge cubes (not corners) have exactly 2 painted faces. A 3×3×3 cube has 12 edge cubes.',
        difficulty: 'Hard',
        subCategory: 'Spatial Reasoning',
      ),
      AptitudeQuestion(
        id: 'sr2',
        question: 'If you fold a piece of paper in half twice and cut a hole, how many holes will there be when unfolded?',
        options: ['1', '2', '4', '8'],
        correctAnswer: 2,
        explanation: 'Folding twice creates 4 layers. One cut creates 4 holes when unfolded.',
        difficulty: 'Medium',
        subCategory: 'Spatial Reasoning',
      ),
      AptitudeQuestion(
        id: 'sr3',
        question: 'A clock shows 3:15. What is the angle between the hour and minute hands?',
        options: ['0°', '7.5°', '15°', '22.5°'],
        correctAnswer: 1,
        explanation: 'Minute hand at 90°. Hour hand moves 0.5° per minute: 3:15 = 97.5°. Difference = 7.5°',
        difficulty: 'Hard',
        subCategory: 'Spatial Reasoning',
      ),
      AptitudeQuestion(
        id: 'sr4',
        question: 'How many triangles can you count in a figure made of 4 triangular sections arranged in a larger triangle?',
        options: ['4', '8', '13', '16'],
        correctAnswer: 2,
        explanation: 'Count: 4 small + 6 medium (combinations of 2) + 2 large (combinations of 3) + 1 whole = 13',
        difficulty: 'Hard',
        subCategory: 'Spatial Reasoning',
      ),
      AptitudeQuestion(
        id: 'sr5',
        question: 'If a square is rotated 45 degrees, what shape does its shadow most resemble?',
        options: ['Square', 'Diamond', 'Octagon', 'Circle'],
        correctAnswer: 1,
        explanation: 'A square rotated 45° appears as a diamond shape.',
        difficulty: 'Easy',
        subCategory: 'Spatial Reasoning',
      ),
    ];
  }

  static List<AptitudeQuestion> getDeductiveLogicQuestions() {
    return [
      AptitudeQuestion(
        id: 'dl1',
        question: 'All cats are mammals. Some mammals are pets. Which conclusion follows?',
        options: ['All cats are pets', 'Some cats are pets', 'No cats are pets', 'Some cats may be pets'],
        correctAnswer: 3,
        explanation: 'We cannot determine if cats are among the mammals that are pets, only that it\'s possible.',
        difficulty: 'Medium',
        subCategory: 'Deductive Logic',
      ),
      AptitudeQuestion(
        id: 'dl2',
        question: 'If A implies B, and B implies C, what can we conclude about A and C?',
        options: ['A implies C', 'C implies A', 'A equals C', 'No relationship'],
        correctAnswer: 0,
        explanation: 'By transitivity: If A→B and B→C, then A→C',
        difficulty: 'Medium',
        subCategory: 'Deductive Logic',
      ),
      AptitudeQuestion(
        id: 'dl3',
        question: 'In a group where everyone who likes pizza also likes cheese, and John doesn\'t like cheese, what can we conclude?',
        options: ['John likes pizza', 'John doesn\'t like pizza', 'John might like pizza', 'Cannot determine'],
        correctAnswer: 1,
        explanation: 'If liking pizza implies liking cheese, and John doesn\'t like cheese, then John cannot like pizza.',
        difficulty: 'Medium',
        subCategory: 'Deductive Logic',
      ),
      AptitudeQuestion(
        id: 'dl4',
        question: 'All squares are rectangles. All rectangles are quadrilaterals. Therefore:',
        options: ['All quadrilaterals are squares', 'All squares are quadrilaterals', 'Some quadrilaterals are squares', 'No relationship exists'],
        correctAnswer: 1,
        explanation: 'By transitivity: squares → rectangles → quadrilaterals, so all squares are quadrilaterals.',
        difficulty: 'Easy',
        subCategory: 'Deductive Logic',
      ),
      AptitudeQuestion(
        id: 'dl5',
        question: 'If "No fish are mammals" and "All whales are mammals", what follows about whales and fish?',
        options: ['All whales are fish', 'No whales are fish', 'Some whales are fish', 'Cannot determine'],
        correctAnswer: 1,
        explanation: 'Since whales are mammals and no fish are mammals, no whales can be fish.',
        difficulty: 'Medium',
        subCategory: 'Deductive Logic',
      ),
    ];
  }

  static List<AptitudeQuestion> getQuestionsByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'pattern recognition':
        return getPatternRecognitionQuestions();
      case 'logical sequences':
        return getLogicalSequenceQuestions();
      case 'analytical reasoning':
        return getAnalyticalReasoningQuestions();
      case 'critical thinking':
        return getCriticalThinkingQuestions();
      case 'spatial reasoning':
        return getSpatialReasoningQuestions();
      case 'deductive logic':
        return getDeductiveLogicQuestions();
      default:
        return getAllQuestions();
    }
  }
}
