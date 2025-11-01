import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class UserCourseService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const String _coursesEndpoint = '/courses';
  static const String _progressEndpoint = '/progress';

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

  // Get current user ID
  static String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Get enrolled courses for current user
  static Future<List<Map<String, dynamic>>> getEnrolledCourses() async {
    if (_currentUserId == null) return [];

    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/user/enrolled'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  // Get available courses (not enrolled)
  static Future<List<Map<String, dynamic>>> getAvailableCourses() async {
    if (_currentUserId == null) return [];

    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/user/available'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  // Enroll in a course
  static Future<Map<String, dynamic>> enrollInCourse(String courseId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/enroll'),
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to enroll in course: ${response.body}');
    }
  }

  // Unenroll from a course
  static Future<void> unenrollFromCourse(String courseId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/enroll'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unenroll from course: ${response.body}');
    }
  }

  // Get course details with user-specific data
  static Future<Map<String, dynamic>> getCourseDetails(String courseId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/user/details'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get course details: ${response.body}');
    }
  }

  // Get course progress
  static Future<Map<String, dynamic>> getCourseProgress(String courseId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_progressEndpoint/course/$courseId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get course progress: ${response.body}');
    }
  }

  // Update topic progress
  static Future<Map<String, dynamic>> updateTopicProgress(
    String courseId,
    String topicId,
    double progress,
  ) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl$_progressEndpoint/topic'),
      headers: headers,
      body: json.encode({
        'courseId': courseId,
        'topicId': topicId,
        'progress': progress,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update topic progress: ${response.body}');
    }
  }

  // Mark topic as completed
  static Future<Map<String, dynamic>> markTopicCompleted(
    String courseId,
    String topicId,
  ) async {
    return await updateTopicProgress(courseId, topicId, 100.0);
  }

  // Get user's learning statistics
  static Future<Map<String, dynamic>> getLearningStats() async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_progressEndpoint/user/stats'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get learning stats: ${response.body}');
    }
  }

  // Get recommended courses based on user preferences
  static Future<List<Map<String, dynamic>>> getRecommendedCourses() async {
    if (_currentUserId == null) return [];

    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/user/recommendations'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  // Search courses
  static Future<List<Map<String, dynamic>>> searchCourses(String query) async {
    if (_currentUserId == null) return [];

    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/search?q=$query'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  // Get course certificates
  static Future<List<Map<String, dynamic>>> getCertificates() async {
    if (_currentUserId == null) return [];

    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/user/certificates'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  // Download certificate for completed course
  static Future<Map<String, dynamic>> downloadCertificate(String courseId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/certificate'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to download certificate: ${response.body}');
    }
  }

  // Get user's course history
  static Future<List<Map<String, dynamic>>> getCourseHistory() async {
    if (_currentUserId == null) return [];

    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/user/history'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  // Get upcoming courses
  static Future<List<Map<String, dynamic>>> getUpcomingCourses() async {
    if (_currentUserId == null) return [];

    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/user/upcoming'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  // Get course notifications
  static Future<List<Map<String, dynamic>>> getCourseNotifications() async {
    if (_currentUserId == null) return [];

    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/user/notifications'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  // Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    if (_currentUserId == null) return;

    final headers = await _getAuthHeaders();
    await http.patch(
      Uri.parse('$_baseUrl$_coursesEndpoint/notifications/$notificationId/read'),
      headers: headers,
    );
  }

  // Get user's favorite courses
  static Future<List<Map<String, dynamic>>> getFavoriteCourses() async {
    if (_currentUserId == null) return [];

    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/user/favorites'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  // Toggle favorite course
  static Future<void> toggleFavoriteCourse(String courseId) async {
    if (_currentUserId == null) return;

    final headers = await _getAuthHeaders();
    await http.post(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/favorite'),
      headers: headers,
    );
  }

  // Get course reviews
  static Future<List<Map<String, dynamic>>> getCourseReviews(String courseId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/reviews'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  // Submit course review
  static Future<Map<String, dynamic>> submitCourseReview(
    String courseId,
    int rating,
    String review,
  ) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl$_coursesEndpoint/$courseId/reviews'),
      headers: headers,
      body: json.encode({
        'rating': rating,
        'review': review,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit review: ${response.body}');
    }
  }
}
