// lib/screens/ai_bot_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ai_service.dart';

class AIBotScreen extends StatefulWidget {
  const AIBotScreen({super.key});

  @override
  AIBotScreenState createState() => AIBotScreenState();
}

class AIBotScreenState extends State<AIBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _addMessage(
      sender: 'bot',
      text: 'Hi! I\'m your placement assistant. How can I help you today?',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage({required String sender, required String text}) {
    setState(() {
      _messages.add({
        'sender': sender,
        'text': text,
        'timestamp': DateTime.now(),
      });
    });
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    String userMessage = _messageController.text.trim();
    _messageController.clear();
    
    // Add user message
    _addMessage(sender: 'user', text: userMessage);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Try AI backend first
      final aiResponse = await AIService.chatWithBot(userMessage);
      
      if (aiResponse['success'] == true) {
        _addMessage(sender: 'bot', text: aiResponse['response']);
      } else {
        // Fallback to Firestore responses
        QuerySnapshot responseSnapshot = await FirebaseFirestore.instance
            .collection('chat_responses')
            .where('keywords', arrayContainsAny: userMessage.toLowerCase().split(' '))
            .limit(1)
            .get();
        
        if (responseSnapshot.docs.isNotEmpty) {
          var responseData = responseSnapshot.docs.first.data() as Map<String, dynamic>;
          _addMessage(sender: 'bot', text: responseData['answer'] ?? 'I\'m not sure how to respond to that.');
        } else {
          // Final fallback
          String response = _getFallbackResponse(userMessage);
          _addMessage(sender: 'bot', text: response);
        }
      }
    } catch (e) {
      debugPrint('Chat error: $e');
      _addMessage(sender: 'bot', text: 'Sorry, I encountered an error. Please try again later.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getFallbackResponse(String message) {
    message = message.toLowerCase();
    
    if (message.contains('interview') && message.contains('question')) {
      return 'Common interview questions include:\n\n1. Tell me about yourself.\n2. Why do you want to work here?\n3. What are your strengths and weaknesses?\n4. Where do you see yourself in 5 years?\n5. Why should we hire you?';
    } else if (message.contains('resume') || message.contains('cv')) {
      return 'A good resume should:\n\n• Be clear and concise\n• Highlight relevant skills and experience\n• Use action verbs\n• Be tailored to the job you\'re applying for\n• Be free of typos and grammatical errors';
    } else if (message.contains('aptitude') || message.contains('test')) {
      return 'To prepare for aptitude tests:\n\n• Practice regularly\n• Work on your speed and accuracy\n• Review basic math concepts\n• Learn shortcuts for calculations\n• Take mock tests to assess your preparation';
    } else if (message.contains('group') && message.contains('discussion')) {
      return 'Tips for group discussions:\n\n• Be confident but not aggressive\n• Listen to others before speaking\n• Support your points with facts\n• Be a team player\n• Maintain eye contact with all participants';
    } else {
      return 'I\'m here to help with placement-related queries. You can ask me about interview questions, resume tips, aptitude preparation, or any other placement-related topic.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Placement Assistant'),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                
                return Row(
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isUser)
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.smart_toy, color: Colors.white),
                      ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                            fontSize: 16,
                            color: isUser ? Colors.blue[900] : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isUser)
                      const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                  ],
                );
              },
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}