import '../models/aptitude_quiz.dart';

class AptitudeQuizData {
  static List<AptitudeQuiz> getAllQuizzes() {
    return [
      _getQuantitativeAptitudeQuiz(),
      _getLogicalReasoningQuiz(),
      _getVerbalAbilityQuiz(),
      _getDataInterpretationQuiz(),
      _getProgrammingLogicQuiz(),
    ];
  }

  static AptitudeQuiz _getQuantitativeAptitudeQuiz() {
    return AptitudeQuiz(
      id: 'quant_001',
      title: 'Quantitative Aptitude',
      description: 'Test your mathematical and numerical skills',
      category: 'Quantitative',
      timeLimit: 30,
      difficulty: 'Medium',
      questions: [
        AptitudeQuestion(
          id: 'q1',
          question: 'If a train travels 120 km in 2 hours, what is its speed in km/h?',
          options: ['50 km/h', '60 km/h', '70 km/h', '80 km/h'],
          correctAnswer: 1,
          explanation: 'Speed = Distance/Time = 120/2 = 60 km/h',
          difficulty: 'Easy',
          subCategory: 'Speed and Distance',
        ),
        AptitudeQuestion(
          id: 'q2',
          question: 'What is 15% of 240?',
          options: ['30', '36', '42', '48'],
          correctAnswer: 1,
          explanation: '15% of 240 = (15/100) × 240 = 36',
          difficulty: 'Easy',
          subCategory: 'Percentage',
        ),
        AptitudeQuestion(
          id: 'q3',
          question: 'A shopkeeper marks his goods 40% above cost price and gives a discount of 25%. What is his profit percentage?',
          options: ['5%', '10%', '15%', '20%'],
          correctAnswer: 0,
          explanation: 'Let CP = 100. MP = 140. SP = 140 × 0.75 = 105. Profit% = 5%',
          difficulty: 'Medium',
          subCategory: 'Profit and Loss',
        ),
        AptitudeQuestion(
          id: 'q4',
          question: 'In how many ways can 5 people sit in a row?',
          options: ['60', '120', '240', '360'],
          correctAnswer: 1,
          explanation: '5! = 5 × 4 × 3 × 2 × 1 = 120',
          difficulty: 'Medium',
          subCategory: 'Permutation',
        ),
        AptitudeQuestion(
          id: 'q5',
          question: 'If the ratio of ages of A and B is 3:4 and sum of their ages is 35, what is A\'s age?',
          options: ['12', '15', '18', '21'],
          correctAnswer: 1,
          explanation: 'Let ages be 3x and 4x. 3x + 4x = 35, so 7x = 35, x = 5. A\'s age = 3×5 = 15',
          difficulty: 'Medium',
          subCategory: 'Ratio and Proportion',
        ),
      ],
    );
  }

  static AptitudeQuiz _getLogicalReasoningQuiz() {
    return AptitudeQuiz(
      id: 'logic_001',
      title: 'Logical Reasoning',
      description: 'Test your logical thinking and problem-solving skills',
      category: 'Logical',
      timeLimit: 45,
      difficulty: 'Medium',
      questions: [
        // Number Series Questions
        AptitudeQuestion(
          id: 'l1',
          question: 'Find the next number in the series: 2, 6, 12, 20, 30, ?',
          options: ['40', '42', '44', '46'],
          correctAnswer: 1,
          explanation: 'Pattern: 1×2, 2×3, 3×4, 4×5, 5×6, 6×7 = 42',
          difficulty: 'Medium',
          subCategory: 'Number Series',
        ),
        AptitudeQuestion(
          id: 'l2',
          question: 'Which number should replace the question mark?\n8, 27, 64, 125, ?',
          options: ['196', '216', '256', '343'],
          correctAnswer: 1,
          explanation: 'These are cubes: 2³, 3³, 4³, 5³, 6³ = 216',
          difficulty: 'Easy',
          subCategory: 'Number Series',
        ),
        AptitudeQuestion(
          id: 'l3',
          question: 'Find the missing number: 5, 11, 23, 47, 95, ?',
          options: ['191', '189', '193', '187'],
          correctAnswer: 0,
          explanation: 'Pattern: Each number is (previous × 2) + 1. 95 × 2 + 1 = 191',
          difficulty: 'Medium',
          subCategory: 'Number Series',
        ),
        AptitudeQuestion(
          id: 'l4',
          question: 'Complete the series: 1, 4, 9, 16, 25, ?',
          options: ['30', '32', '36', '49'],
          correctAnswer: 2,
          explanation: 'Perfect squares: 1², 2², 3², 4², 5², 6² = 36',
          difficulty: 'Easy',
          subCategory: 'Number Series',
        ),
        AptitudeQuestion(
          id: 'l5',
          question: 'What comes next: 3, 7, 15, 31, 63, ?',
          options: ['127', '125', '129', '131'],
          correctAnswer: 0,
          explanation: 'Pattern: Each number is (previous × 2) + 1. 63 × 2 + 1 = 127',
          difficulty: 'Medium',
          subCategory: 'Number Series',
        ),
        
        // Coding-Decoding Questions
        AptitudeQuestion(
          id: 'l6',
          question: 'If CODING is written as DPEJOH, how is FLOWER written?',
          options: ['GMPXFS', 'GMPWFS', 'GKPXFS', 'GMPXFR'],
          correctAnswer: 0,
          explanation: 'Each letter is shifted by +1 position: F→G, L→M, O→P, W→X, E→F, R→S',
          difficulty: 'Medium',
          subCategory: 'Coding-Decoding',
        ),
        AptitudeQuestion(
          id: 'l7',
          question: 'In a certain code, CHAIR is written as 12345 and REACH is written as 51624. How is CARE written?',
          options: ['2451', '2415', '1254', '1245'],
          correctAnswer: 1,
          explanation: 'C=2, A=4, R=1, E=5. So CARE = 2415',
          difficulty: 'Medium',
          subCategory: 'Coding-Decoding',
        ),
        AptitudeQuestion(
          id: 'l8',
          question: 'If MOTHER is coded as NQWKHU, then FATHER is coded as:',
          options: ['GCWKHU', 'HCVKGT', 'GCVKGT', 'HCWKHU'],
          correctAnswer: 2,
          explanation: 'Each letter is shifted +3 positions: F→G, A→C, T→V, H→K, E→G, R→T',
          difficulty: 'Medium',
          subCategory: 'Coding-Decoding',
        ),
        AptitudeQuestion(
          id: 'l9',
          question: 'If CAT = 312 and DOG = 415, then BIRD = ?',
          options: ['2948', '2849', '2894', '2984'],
          correctAnswer: 0,
          explanation: 'A=1, B=2, C=3, D=4... So B=2, I=9, R=18→8, D=4. BIRD = 2948',
          difficulty: 'Hard',
          subCategory: 'Coding-Decoding',
        ),
        AptitudeQuestion(
          id: 'l10',
          question: 'In a code language, WATER is written as XBUFS. How is EARTH written?',
          options: ['FBSUI', 'FBSUJ', 'FBSUK', 'FBSUM'],
          correctAnswer: 0,
          explanation: 'Each letter is shifted +1: E→F, A→B, R→S, T→U, H→I',
          difficulty: 'Easy',
          subCategory: 'Coding-Decoding',
        ),
        
        // Syllogism Questions
        AptitudeQuestion(
          id: 'l11',
          question: 'All roses are flowers. Some flowers are red. Which conclusion follows?\n1. Some roses are red\n2. All flowers are roses',
          options: ['Only 1', 'Only 2', 'Both 1 and 2', 'Neither 1 nor 2'],
          correctAnswer: 3,
          explanation: 'Neither conclusion necessarily follows from the given statements.',
          difficulty: 'Hard',
          subCategory: 'Syllogism',
        ),
        AptitudeQuestion(
          id: 'l12',
          question: 'All cats are animals. Some animals are wild. Conclusions:\n1. Some cats are wild\n2. All wild animals are cats',
          options: ['Only 1', 'Only 2', 'Both 1 and 2', 'Neither 1 nor 2'],
          correctAnswer: 3,
          explanation: 'No definite conclusion can be drawn from the given statements.',
          difficulty: 'Medium',
          subCategory: 'Syllogism',
        ),
        AptitudeQuestion(
          id: 'l13',
          question: 'All books are papers. All papers are white. Conclusions:\n1. All books are white\n2. Some white things are books',
          options: ['Only 1', 'Only 2', 'Both 1 and 2', 'Neither 1 nor 2'],
          correctAnswer: 2,
          explanation: 'Both conclusions follow logically from the given statements.',
          difficulty: 'Medium',
          subCategory: 'Syllogism',
        ),
        
        // Pattern Recognition
        AptitudeQuestion(
          id: 'l14',
          question: 'Which figure completes the pattern?\n△ ○ □ △ ○ ?',
          options: ['△', '○', '□', '◇'],
          correctAnswer: 2,
          explanation: 'The pattern repeats every 3 figures: triangle, circle, square',
          difficulty: 'Easy',
          subCategory: 'Pattern Recognition',
        ),
        AptitudeQuestion(
          id: 'l15',
          question: 'Find the odd one out: 16, 25, 36, 49, 50',
          options: ['16', '25', '36', '50'],
          correctAnswer: 3,
          explanation: '50 is not a perfect square. Others are: 4², 5², 6², 7²',
          difficulty: 'Easy',
          subCategory: 'Pattern Recognition',
        ),
        
        // Logical Deduction
        AptitudeQuestion(
          id: 'l16',
          question: 'If all Bloops are Razzles and all Razzles are Lazzles, then all Bloops are definitely Lazzles.',
          options: ['True', 'False', 'Cannot be determined', 'Insufficient data'],
          correctAnswer: 0,
          explanation: 'This follows the transitive property: If A→B and B→C, then A→C',
          difficulty: 'Medium',
          subCategory: 'Logical Deduction',
        ),
        AptitudeQuestion(
          id: 'l17',
          question: 'In a family of 6, A is the father of C. B is the mother of C. D is the brother of A. E is the wife of D. F is the daughter of E. What is the relationship between F and C?',
          options: ['Sister', 'Cousin', 'Aunt', 'Niece'],
          correctAnswer: 1,
          explanation: 'F is D\'s daughter, D is A\'s brother, C is A\'s child. So F and C are cousins.',
          difficulty: 'Hard',
          subCategory: 'Logical Deduction',
        ),
        
        // Direction and Distance
        AptitudeQuestion(
          id: 'l18',
          question: 'A man walks 5 km North, then 3 km East, then 2 km South. How far is he from the starting point?',
          options: ['√18 km', '√15 km', '√12 km', '√10 km'],
          correctAnswer: 0,
          explanation: 'Final position: 3 km East, 3 km North. Distance = √(3² + 3²) = √18 km',
          difficulty: 'Medium',
          subCategory: 'Direction & Distance',
        ),
        AptitudeQuestion(
          id: 'l19',
          question: 'Starting from home, Raj walks 10m North, then 6m West, then 10m South, then 6m East. Where is he now?',
          options: ['At home', '12m from home', '6m North of home', '10m West of home'],
          correctAnswer: 0,
          explanation: 'He returns to the starting point after completing a rectangle.',
          difficulty: 'Easy',
          subCategory: 'Direction & Distance',
        ),
        
        // Blood Relations
        AptitudeQuestion(
          id: 'l20',
          question: 'Pointing to a photograph, a man said "She is the daughter of my grandfather\'s only son." Who is the woman in the photograph?',
          options: ['His sister', 'His daughter', 'His mother', 'His wife'],
          correctAnswer: 0,
          explanation: 'Grandfather\'s only son = his father. Daughter of his father = his sister.',
          difficulty: 'Medium',
          subCategory: 'Blood Relations',
        ),
      ],
    );
  }

  static AptitudeQuiz _getVerbalAbilityQuiz() {
    return AptitudeQuiz(
      id: 'verbal_001',
      title: 'Verbal Ability',
      description: 'Test your English language and comprehension skills',
      category: 'Verbal',
      timeLimit: 20,
      difficulty: 'Medium',
      questions: [
        AptitudeQuestion(
          id: 'v1',
          question: 'Choose the word that is most similar in meaning to "ABUNDANT"',
          options: ['Scarce', 'Plentiful', 'Limited', 'Rare'],
          correctAnswer: 1,
          explanation: 'Abundant means existing in large quantities; plentiful.',
          difficulty: 'Easy',
          subCategory: 'Synonyms',
        ),
        AptitudeQuestion(
          id: 'v2',
          question: 'Choose the word that is opposite in meaning to "OPTIMISTIC"',
          options: ['Hopeful', 'Positive', 'Pessimistic', 'Confident'],
          correctAnswer: 2,
          explanation: 'Optimistic means hopeful and confident about the future; pessimistic is the opposite.',
          difficulty: 'Easy',
          subCategory: 'Antonyms',
        ),
        AptitudeQuestion(
          id: 'v3',
          question: 'Complete the sentence: "Despite the heavy rain, the match _____ as scheduled."',
          options: ['proceeded', 'preceded', 'receded', 'succeeded'],
          correctAnswer: 0,
          explanation: 'Proceeded means continued or went forward, which fits the context.',
          difficulty: 'Medium',
          subCategory: 'Sentence Completion',
        ),
        AptitudeQuestion(
          id: 'v4',
          question: 'Find the correctly spelled word:',
          options: ['Accomodate', 'Accommodate', 'Acommodate', 'Acomodate'],
          correctAnswer: 1,
          explanation: 'The correct spelling is "Accommodate" with double c and double m.',
          difficulty: 'Medium',
          subCategory: 'Spelling',
        ),
        AptitudeQuestion(
          id: 'v5',
          question: 'Choose the grammatically correct sentence:',
          options: [
            'Neither of the students have completed their assignment.',
            'Neither of the students has completed their assignment.',
            'Neither of the students have completed his assignment.',
            'Neither of the students has completed his assignment.'
          ],
          correctAnswer: 1,
          explanation: '"Neither" is singular, so it takes "has". "Their" is acceptable for gender-neutral reference.',
          difficulty: 'Hard',
          subCategory: 'Grammar',
        ),
      ],
    );
  }

  static AptitudeQuiz _getDataInterpretationQuiz() {
    return AptitudeQuiz(
      id: 'di_001',
      title: 'Data Interpretation',
      description: 'Test your ability to analyze and interpret data',
      category: 'Data Interpretation',
      timeLimit: 35,
      difficulty: 'Hard',
      questions: [
        AptitudeQuestion(
          id: 'd1',
          question: 'A company\'s sales for 5 months are: Jan-100, Feb-120, Mar-150, Apr-130, May-160. What is the average monthly sales?',
          options: ['124', '132', '140', '148'],
          correctAnswer: 1,
          explanation: 'Average = (100+120+150+130+160)/5 = 660/5 = 132',
          difficulty: 'Easy',
          subCategory: 'Basic Statistics',
        ),
        AptitudeQuestion(
          id: 'd2',
          question: 'In a pie chart, if a sector represents 72°, what percentage of the total does it represent?',
          options: ['15%', '18%', '20%', '25%'],
          correctAnswer: 2,
          explanation: 'Percentage = (72°/360°) × 100% = 20%',
          difficulty: 'Medium',
          subCategory: 'Pie Charts',
        ),
        AptitudeQuestion(
          id: 'd3',
          question: 'A bar chart shows production: 2020-200 units, 2021-250 units, 2022-300 units. What is the percentage increase from 2020 to 2022?',
          options: ['40%', '45%', '50%', '55%'],
          correctAnswer: 2,
          explanation: 'Increase = (300-200)/200 × 100% = 100/200 × 100% = 50%',
          difficulty: 'Medium',
          subCategory: 'Bar Charts',
        ),
        AptitudeQuestion(
          id: 'd4',
          question: 'Given data: 10, 15, 20, 25, 30. What is the median?',
          options: ['15', '18', '20', '22'],
          correctAnswer: 2,
          explanation: 'For odd number of values, median is the middle value = 20',
          difficulty: 'Easy',
          subCategory: 'Median',
        ),
        AptitudeQuestion(
          id: 'd5',
          question: 'If the ratio of boys to girls in a class is 3:2 and there are 30 students total, how many girls are there?',
          options: ['10', '12', '15', '18'],
          correctAnswer: 1,
          explanation: 'Total parts = 3+2 = 5. Girls = (2/5) × 30 = 12',
          difficulty: 'Medium',
          subCategory: 'Ratios',
        ),
      ],
    );
  }

  static AptitudeQuiz _getProgrammingLogicQuiz() {
    return AptitudeQuiz(
      id: 'prog_001',
      title: 'Programming Logic',
      description: 'Test your programming and algorithmic thinking',
      category: 'Programming',
      timeLimit: 40,
      difficulty: 'Hard',
      questions: [
        AptitudeQuestion(
          id: 'p1',
          question: 'What will be the output of this pseudocode?\nfor i = 1 to 3\n  for j = 1 to 2\n    print i*j\nend',
          options: ['1 2 2 4 3 6', '1 2 3 2 4 6', '2 4 6 1 2 3', '1 1 2 2 3 3'],
          correctAnswer: 0,
          explanation: 'Nested loops: i=1: 1*1=1, 1*2=2; i=2: 2*1=2, 2*2=4; i=3: 3*1=3, 3*2=6',
          difficulty: 'Medium',
          subCategory: 'Loops',
        ),
        AptitudeQuestion(
          id: 'p2',
          question: 'What is the time complexity of binary search?',
          options: ['O(n)', 'O(log n)', 'O(n log n)', 'O(n²)'],
          correctAnswer: 1,
          explanation: 'Binary search divides the search space in half each time, resulting in O(log n) complexity.',
          difficulty: 'Medium',
          subCategory: 'Time Complexity',
        ),
        AptitudeQuestion(
          id: 'p3',
          question: 'Which data structure uses LIFO (Last In First Out) principle?',
          options: ['Queue', 'Stack', 'Array', 'Linked List'],
          correctAnswer: 1,
          explanation: 'Stack follows LIFO principle where the last element added is the first to be removed.',
          difficulty: 'Easy',
          subCategory: 'Data Structures',
        ),
        AptitudeQuestion(
          id: 'p4',
          question: 'What will be the value of x after this code?\nx = 5\nx = x + 3\nx = x * 2',
          options: ['13', '16', '18', '21'],
          correctAnswer: 1,
          explanation: 'x = 5, then x = 5+3 = 8, then x = 8*2 = 16',
          difficulty: 'Easy',
          subCategory: 'Variables',
        ),
        AptitudeQuestion(
          id: 'p5',
          question: 'Which sorting algorithm has the best average case time complexity?',
          options: ['Bubble Sort', 'Selection Sort', 'Quick Sort', 'Insertion Sort'],
          correctAnswer: 2,
          explanation: 'Quick Sort has O(n log n) average case complexity, which is better than O(n²) for others listed.',
          difficulty: 'Hard',
          subCategory: 'Algorithms',
        ),
      ],
    );
  }
}
