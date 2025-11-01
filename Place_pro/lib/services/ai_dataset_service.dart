import 'dart:math';

class AIDatasetService {
  static final AIDatasetService _instance = AIDatasetService._internal();
  factory AIDatasetService() => _instance;
  AIDatasetService._internal();

  final Random _random = Random();

  // Mock dataset for responses
  final Map<String, List<String>> _responseDatabase = {
    'interview': [
      'Tell me about yourself: Start with your background, education, and relevant experience. Keep it concise and focused on your strengths.',
      'What are your strengths? Focus on 2-3 key strengths that are relevant to the position. Provide specific examples.',
      'What are your weaknesses? Mention a real weakness but show how you are working to improve it.',
      'Why do you want to work here? Research the company thoroughly and align your goals with their mission and values.',
      'Where do you see yourself in 5 years? Show ambition but stay realistic. Focus on growth within the company.',
      'Why should we hire you? Highlight your unique value proposition and how you can solve their problems.',
      'Do you have any questions for us? Always prepare thoughtful questions about the role, team, and company.',
    ],
    'resume': [
      'Keep your resume to 1-2 pages maximum. Use bullet points and quantify achievements with numbers.',
      'Start with a strong summary statement that highlights your key skills and experience.',
      'Use action verbs like "led," "managed," "increased," "improved" to describe your accomplishments.',
      'Tailor your resume for each job application by using keywords from the job description.',
      'Include relevant coursework, projects, and internships if you have limited work experience.',
      'Proofread carefully - even one typo can hurt your chances significantly.',
    ],
    'aptitude': [
      'Practice mental math daily - focus on percentages, ratios, and quick calculations.',
      'Learn common patterns: arithmetic, geometric, and logical sequences.',
      'Master time management - spend max 45 seconds per question in online tests.',
      'Practice with previous year papers and mock tests from platforms like Indiabix.',
      'Focus on areas: quantitative aptitude, logical reasoning, and verbal ability.',
      'Create a formula sheet for quick reference during practice sessions.',
    ],
    'group_discussion': [
      'Start strong with a clear, confident opening statement if you have domain knowledge.',
      'Listen actively and build on others points rather than just waiting to speak.',
      'Use phrases like "I agree with X and would like to add..." or "Building on that point..."',
      'Maintain good body language - sit upright, make eye contact, and use hand gestures.',
      'Bring the discussion back on track if it goes off-topic: "Let us refocus on the main issue..."',
      'Summarize key points periodically to show leadership and analytical skills.',
    ],
    'technical': [
      'Practice coding on platforms like LeetCode, HackerRank, and CodeChef regularly.',
      'Master data structures: arrays, linked lists, trees, graphs, and hash maps.',
      'Understand time and space complexity - Big O notation is crucial.',
      'Prepare system design basics for senior roles - scalability, databases, APIs.',
      'Create a GitHub portfolio with 3-4 good projects showcasing different skills.',
      'Be ready to explain your code and thought process clearly during interviews.',
    ],
    'salary': [
      'Research market rates using Glassdoor, Payscale, and LinkedIn salary insights.',
      'Never discuss salary in the first interview - focus on learning about the role first.',
      'Have a specific range ready based on your research and experience level.',
      'Consider the total package: base salary, bonuses, stock options, benefits.',
      'Practice negotiation phrases: "Based on my research and experience..."',
      'Be prepared to walk away if the offer does not meet your minimum requirements.',
    ],
    'networking': [
      'Create a strong LinkedIn profile with professional photo and detailed experience.',
      'Attend industry meetups, conferences, and alumni events regularly.',
      'Reach out to alumni from your college working in target companies.',
      'Prepare a 30-second elevator pitch about yourself and your career goals.',
      'Follow up within 24-48 hours after meeting someone new.',
      'Offer value to your network - share articles, make introductions, provide insights.',
    ],
    'career': [
      'Set SMART goals: Specific, Measurable, Achievable, Relevant, Time-bound.',
      'Create a 5-year career plan with quarterly milestones and regular reviews.',
      'Identify skill gaps and create a learning plan to address them.',
      'Build a personal brand through blogging, speaking, or open-source contributions.',
      'Find mentors both within and outside your organization.',
      'Stay updated with industry trends through courses, certifications, and reading.',
    ],
    'soft_skills': [
      'Practice active listening - focus on understanding rather than just responding.',
      'Develop emotional intelligence by understanding your triggers and managing reactions.',
      'Improve presentation skills through Toastmasters or similar organizations.',
      'Learn conflict resolution techniques and practice in low-stakes situations.',
      'Build cross-cultural communication skills in today global workplace.',
      'Seek feedback regularly and act on it to show continuous improvement.',
    ],
    'job_search': [
      'Apply the 80-20 rule: 80% networking, 20% online applications for better results.',
      'Customize each application - never use a generic resume or cover letter.',
      'Track all applications in a spreadsheet with follow-up dates and outcomes.',
      'Prepare for different interview formats: phone, video, panel, and case interviews.',
      'Build a portfolio website showcasing your best work and projects.',
      'Practice salary negotiation before you need it - role-play with friends.',
    ],
  };

  // Initialize embeddings (mock implementation)
  Future<void> initializeEmbeddings() async {
    // In a real implementation, this would initialize ML models
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Get response based on user query
  String getAdvancedResponse(String query) {
    final lowerQuery = query.toLowerCase();
    
    // Check for specific keywords and return relevant response
    for (final category in _responseDatabase.keys) {
      if (lowerQuery.contains(category.replaceAll('_', ' '))) {
        final responses = _responseDatabase[category]!;
        return responses[_random.nextInt(responses.length)];
      }
    }
    
    // Check for specific keywords
    if (lowerQuery.contains('tell me about yourself')) {
      return 'Perfect! Here is a structured approach: Start with your current status (student/recent graduate), mention your educational background, highlight 2-3 key skills or experiences, and end with why you are excited about this opportunity. Keep it under 2 minutes.';
    }
    
    if (lowerQuery.contains('strength') || lowerQuery.contains('weakness')) {
      return 'For strengths: Choose 2-3 that are relevant to the role and provide specific examples. For weaknesses: Pick a real area for improvement, show how you are working on it, and demonstrate progress. Never say "I work too hard" - be genuine.';
    }
    
    if (lowerQuery.contains('salary') || lowerQuery.contains('ctc')) {
      return 'Research is key! Check Glassdoor, LinkedIn, and speak with alumni to understand the market range. Always have a range ready, and focus on the total compensation package including benefits, not just base salary.';
    }
    
    if (lowerQuery.contains('resume') || lowerQuery.contains('cv')) {
      return 'Your resume should be ATS-friendly: Use standard fonts, include keywords from the job description, quantify achievements (increased efficiency by 30%), and keep it to 1-2 pages. Always customize for each application!';
    }
    
    if (lowerQuery.contains('aptitude') || lowerQuery.contains('test')) {
      return 'Consistent practice is essential! Use platforms like Indiabix, faceprep, and previous year papers. Focus on time management - spend max 45 seconds per question. Create formula sheets for quick revision.';
    }
    
    // Default response for unrecognized queries
    return 'I understand you are asking about "$query". Could you please be more specific? For example, you could ask about:\n\n'
        '• Interview preparation tips\n'
        '• Resume writing guidance\n'
        '• Aptitude test strategies\n'
        '• Group discussion techniques\n'
        '• Technical interview prep\n'
        '• Salary negotiation\n'
        '• Networking strategies\n'
        '• Career planning advice\n\n'
        'What specific area would you like help with?';
  }

  // Get available categories
  List<String> getAvailableCategories() {
    return _responseDatabase.keys.toList();
  }

  // Get responses for a specific category
  List<String> getResponsesForCategory(String category) {
    return _responseDatabase[category] ?? [];
  }

  // Get total response count
  int getTotalResponseCount() {
    return _responseDatabase.values.fold(0, (sum, list) => sum + list.length);
  }

  // Get random response from a category
  String getRandomResponse(String category) {
    final responses = _responseDatabase[category] ?? [];
    if (responses.isEmpty) {
      return 'No responses available for this category.';
    }
    return responses[_random.nextInt(responses.length)];
  }

  // Search responses based on query
  List<String> searchResponses(String query) {
    final results = <String>[];
    final lowerQuery = query.toLowerCase();
    
    for (final category in _responseDatabase.keys) {
      for (final response in _responseDatabase[category]!) {
        if (response.toLowerCase().contains(lowerQuery)) {
          results.add(response);
        }
      }
    }
    
    return results;
  }

  // Get suggested topics based on input
  List<String> getSuggestedTopics(String input) {
    final suggestions = <String>[];
    final lowerInput = input.toLowerCase();
    
    final topicMap = {
      'interview': ['interview questions', 'interview tips', 'mock interview'],
      'resume': ['resume review', 'cv tips', 'resume format'],
      'aptitude': ['aptitude test', 'quantitative', 'logical reasoning'],
      'technical': ['coding interview', 'technical questions', 'system design'],
      'salary': ['salary negotiation', 'package discussion', 'CTC negotiation'],
      'networking': ['professional networking', 'LinkedIn tips', 'alumni connect'],
    };
    
    for (final entry in topicMap.entries) {
      if (lowerInput.contains(entry.key)) {
        suggestions.addAll(entry.value);
      }
    }
    
    return suggestions.take(3).toList();
  }
}
