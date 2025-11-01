import 'dart:convert';
import 'package:http/http.dart' as http;

class MongoDBService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const String _coursesEndpoint = '/courses';

  // Course CRUD Operations
  static Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await http.get(Uri.parse('$_baseUrl$_coursesEndpoint'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  static Future<Map<String, dynamic>> createCourse(Map<String, dynamic> course) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_coursesEndpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(course),
    );
    return json.decode(response.body);
  }

  static Future<void> deleteCourse(String courseId) async {
    await http.delete(Uri.parse('$_baseUrl$_coursesEndpoint/$courseId'));
  }

  // Topic CRUD Operations
  static Future<List<Map<String, dynamic>>> getTopics(String courseId) async {
    final response = await http.get(Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/topics'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  static Future<Map<String, dynamic>> createTopic(String courseId, Map<String, dynamic> topic) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/topics'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(topic),
    );
    return json.decode(response.body);
  }

  static Future<void> deleteTopic(String courseId, String topicId) async {
    await http.delete(Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/topics/$topicId'));
  }
}
