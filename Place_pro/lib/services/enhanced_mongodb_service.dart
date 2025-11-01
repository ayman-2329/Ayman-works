import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/mongodb_config.dart';

class EnhancedMongoDBService {
  static const String _baseUrl = MongoDBConfig.baseUrl;
  static const String _coursesEndpoint = MongoDBConfig.coursesEndpoint;
  static const String _usersEndpoint = MongoDBConfig.usersEndpoint;

  // Helper method to get authenticated headers
  static Future<Map<String, String>> _getAuthHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  // User Management
  static Future<Map<String, dynamic>> createUserProfile(Map<String, dynamic> userData) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl$_usersEndpoint'),
      headers: headers,
      body: json.encode(userData),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    final headers = await _getAuthHeaders();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    final response = await http.get(
      Uri.parse('$_baseUrl$_usersEndpoint/${user.uid}'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  // Course CRUD Operations with User Context
  static Future<List<Map<String, dynamic>>> getUserCourses() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/user/courses'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  static Future<Map<String, dynamic>> createCourse(Map<String, dynamic> course) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl$_coursesEndpoint'),
      headers: headers,
      body: json.encode(course),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateCourse(String courseId, Map<String, dynamic> updates) async {
    final headers = await _getAuthHeaders();
    final response = await http.patch(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId'),
      headers: headers,
      body: json.encode(updates),
    );
    return json.decode(response.body);
  }

  static Future<void> deleteCourse(String courseId) async {
    final headers = await _getAuthHeaders();
    await http.delete(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId'),
      headers: headers,
    );
  }

  // Course Enrollment
  static Future<Map<String, dynamic>> enrollInCourse(String courseId) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/enroll'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<void> unenrollFromCourse(String courseId) async {
    final headers = await _getAuthHeaders();
    await http.delete(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/enroll'),
      headers: headers,
    );
  }

  // Topic CRUD Operations
  static Future<List<Map<String, dynamic>>> getTopics(String courseId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/topics'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  static Future<Map<String, dynamic>> createTopic(String courseId, Map<String, dynamic> topic) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/topics'),
      headers: headers,
      body: json.encode(topic),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateTopic(String courseId, String topicId, Map<String, dynamic> updates) async {
    final headers = await _getAuthHeaders();
    final response = await http.patch(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/topics/$topicId'),
      headers: headers,
      body: json.encode(updates),
    );
    return json.decode(response.body);
  }

  static Future<void> deleteTopic(String courseId, String topicId) async {
    final headers = await _getAuthHeaders();
    await http.delete(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/topics/$topicId'),
      headers: headers,
    );
  }

  // Progress Tracking
  static Future<Map<String, dynamic>> updateProgress(String courseId, String topicId, double progress) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/progress'),
      headers: headers,
      body: json.encode({'topicId': topicId, 'progress': progress}),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getProgress(String courseId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/progress'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  // Admin Operations
  static Future<List<Map<String, dynamic>>> getAllCourses() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getEnrolledStudents(String courseId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/students'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }
}
