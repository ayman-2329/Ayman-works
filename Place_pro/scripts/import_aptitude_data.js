const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin SDK
const serviceAccount = require('../server/firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Sample aptitude questions data
const aptitudeData = {
  quantitative: [
    {
      id: 'q1',
      question: 'If a train travels 120 km in 2 hours, what is its speed in km/h?',
      options: ['50 km/h', '60 km/h', '70 km/h', '80 km/h'],
      correctAnswer: 1,
      explanation: 'Speed = Distance/Time = 120/2 = 60 km/h',
      difficulty: 'Easy',
      subCategory: 'Speed and Distance'
    },
    {
      id: 'q2',
      question: 'What is 15% of 240?',
      options: ['30', '36', '42', '48'],
      correctAnswer: 1,
      explanation: '15% of 240 = (15/100) × 240 = 36',
      difficulty: 'Easy',
      subCategory: 'Percentage'
    },
    {
      id: 'q3',
      question: 'A shopkeeper marks his goods 40% above cost price and gives a discount of 25%. What is his profit percentage?',
      options: ['5%', '10%', '15%', '20%'],
      correctAnswer: 0,
      explanation: 'Let CP = 100. MP = 140. SP = 140 × 0.75 = 105. Profit% = 5%',
      difficulty: 'Medium',
      subCategory: 'Profit and Loss'
    },
    {
      id: 'q4',
      question: 'In how many ways can 5 people sit in a row?',
      options: ['60', '120', '240', '360'],
      correctAnswer: 1,
      explanation: '5! = 5 × 4 × 3 × 2 × 1 = 120',
      difficulty: 'Medium',
      subCategory: 'Permutation'
    },
    {
      id: 'q5',
      question: 'If the ratio of ages of A and B is 3:4 and sum of their ages is 35, what is A\'s age?',
      options: ['12', '15', '18', '21'],
      correctAnswer: 1,
      explanation: 'Let ages be 3x and 4x. 3x + 4x = 35, so 7x = 35, x = 5. A\'s age = 3×5 = 15',
      difficulty: 'Medium',
      subCategory: 'Ratio and Proportion'
    }
  ],
  verbal: [
    {
      id: 'v1',
      question: 'Choose the word that is most similar in meaning to "ABUNDANT"',
      options: ['Scarce', 'Plentiful', 'Limited', 'Rare'],
      correctAnswer: 1,
      explanation: 'Abundant means existing in large quantities; plentiful.',
      difficulty: 'Easy',
      subCategory: 'Synonyms'
    },
    {
      id: 'v2',
      question: 'Choose the word that is opposite in meaning to "OPTIMISTIC"',
      options: ['Hopeful', 'Positive', 'Pessimistic', 'Confident'],
      correctAnswer: 2,
      explanation: 'Optimistic means hopeful and confident about the future; pessimistic is the opposite.',
      difficulty: 'Easy',
      subCategory: 'Antonyms'
    },
    {
      id: 'v3',
      question: 'Complete the sentence: "Despite the heavy rain, the match _____ as scheduled."',
      options: ['proceeded', 'preceded', 'receded', 'succeeded'],
      correctAnswer: 0,
      explanation: 'Proceeded means continued or went forward, which fits the context.',
      difficulty: 'Medium',
      subCategory: 'Sentence Completion'
    },
    {
      id: 'v4',
      question: 'Find the correctly spelled word:',
      options: ['Accomodate', 'Accommodate', 'Acommodate', 'Acomodate'],
      correctAnswer: 1,
      explanation: 'The correct spelling is "Accommodate" with double c and double m.',
      difficulty: 'Medium',
      subCategory: 'Spelling'
    },
    {
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
      subCategory: 'Grammar'
    }
  ],
  reasoning: [
    {
      id: 'l1',
      question: 'Find the next number in the series: 2, 6, 12, 20, 30, ?',
      options: ['40', '42', '44', '46'],
      correctAnswer: 1,
      explanation: 'Pattern: 1×2, 2×3, 3×4, 4×5, 5×6, 6×7 = 42',
      difficulty: 'Medium',
      subCategory: 'Number Series'
    },
    {
      id: 'l2',
      question: 'If CODING is written as DPEJOH, how is FLOWER written?',
      options: ['GMPXFS', 'GMPWFS', 'GKPXFS', 'GMPXFR'],
      correctAnswer: 0,
      explanation: 'Each letter is shifted by +1 position: F→G, L→M, O→P, W→X, E→F, R→S',
      difficulty: 'Medium',
      subCategory: 'Coding-Decoding'
    },
    {
      id: 'l3',
      question: 'All roses are flowers. Some flowers are red. Which conclusion follows?\n1. Some roses are red\n2. All flowers are roses',
      options: ['Only 1', 'Only 2', 'Both 1 and 2', 'Neither 1 nor 2'],
      correctAnswer: 3,
      explanation: 'Neither conclusion necessarily follows from the given statements.',
      difficulty: 'Hard',
      subCategory: 'Syllogism'
    },
    {
      id: 'l4',
      question: 'In a certain code, CHAIR is written as 12345 and REACH is written as 51624. How is CARE written?',
      options: ['2451', '2415', '1254', '1245'],
      correctAnswer: 1,
      explanation: 'C=2, A=4, R=1, E=5. So CARE = 2415',
      difficulty: 'Medium',
      subCategory: 'Coding-Decoding'
    },
    {
      id: 'l5',
      question: 'Which number should replace the question mark?\n8, 27, 64, 125, ?',
      options: ['196', '216', '256', '343'],
      correctAnswer: 1,
      explanation: 'These are cubes: 2³, 3³, 4³, 5³, 6³ = 216',
      difficulty: 'Easy',
      subCategory: 'Number Series'
    }
  ]
};

async function importAptitudeData() {
  try {
    console.log('Starting aptitude data import...');

    // Import questions for each category
    for (const [category, questions] of Object.entries(aptitudeData)) {
      console.log(`Importing ${category} questions...`);
      
      for (const question of questions) {
        await db.collection('aptitude')
          .doc(category)
          .collection('questions')
          .doc(question.id)
          .set(question);
        
        console.log(`  Added question ${question.id}`);
      }
    }

    console.log('✅ Aptitude data import completed successfully!');
    console.log(`📊 Imported ${Object.values(aptitudeData).flat().length} questions across ${Object.keys(aptitudeData).length} categories`);
    
  } catch (error) {
    console.error('❌ Error importing aptitude data:', error);
  } finally {
    process.exit(0);
  }
}

// Run the import
importAptitudeData();
