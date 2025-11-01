// AI Service for PlacePro - Handles communication with Python backend
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AIService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Get daily tip from AI backend
  static Future<Map<String, dynamic>> getDailyTip() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tip/daily'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load daily tip: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching daily tip: $e');
      return {
        'success': false,
        'tip': 'Stay focused on your goals and maintain a positive mindset.',
        'error': e.toString()
      };
    }
  }
  
  // Get random tip with optional category
  static Future<Map<String, dynamic>> getRandomTip({String? category}) async {
    try {
      String url = '$baseUrl/tip/random';
      if (category != null && category.isNotEmpty) {
        url += '?category=$category';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load random tip: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching random tip: $e');
      return {
        'success': false,
        'tip': 'Keep learning and growing every day.',
        'error': e.toString()
      };
    }
  }
  
  // Generate AI tip
  static Future<Map<String, dynamic>> generateAITip({
    String category = 'general',
    String context = ''
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tip/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category': category,
          'context': context,
        }),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to generate AI tip: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error generating AI tip: $e');
      return {
        'success': false,
        'tip': 'Focus on continuous improvement and learning.',
        'error': e.toString()
      };
    }
  }
  
  // Chat with AI bot
  static Future<Map<String, dynamic>> chatWithBot(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to chat with bot: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error chatting with bot: $e');
      return {
        'success': false,
        'response': 'I\'m sorry, I\'m having trouble processing your request right now. Please try again.',
        'error': e.toString()
      };
    }
  }
  
  // Get chat history
  static Future<Map<String, dynamic>> getChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/history'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching chat history: $e');
      return {
        'success': false,
        'history': [],
        'error': e.toString()
      };
    }
  }
  
  // Clear chat history
  static Future<Map<String, dynamic>> clearChatHistory() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/clear'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to clear chat history: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error clearing chat history: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }
  
  // Get available tip categories
  static Future<List<String>> getTipCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tip/categories'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<String>.from(data['categories']);
        }
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return ['productivity', 'career', 'wellness', 'learning', 'general'];
    }
  }
  
  // Check if AI backend is available
  static Future<bool> isBackendAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Backend not available: $e');
      return false;
    }
  }
}
