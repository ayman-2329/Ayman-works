import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthMongoBridge {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const String _usersEndpoint = '/users';
  static const String _authEndpoint = '/auth';

  // Sync Firebase user with MongoDB
  static Future<Map<String, dynamic>> syncUserWithMongoDB() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      final userData = {
        'firebaseUid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final token = await user.getIdToken();
      final response = await http.post(
        Uri.parse('$_baseUrl$_usersEndpoint/sync'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to sync user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error syncing user: $e');
    }
  }

  // Get MongoDB user profile using Firebase UID
  static Future<Map<String, dynamic>> getMongoUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse('$_baseUrl$_usersEndpoint/${user.uid}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        // User doesn't exist in MongoDB, create it
        return await syncUserWithMongoDB();
      } else {
        throw Exception('Failed to get user profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting user profile: $e');
    }
  }

  // Update MongoDB user profile
  static Future<Map<String, dynamic>> updateMongoUserProfile(Map<String, dynamic> updates) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      final token = await user.getIdToken();
      final response = await http.patch(
        Uri.parse('$_baseUrl$_usersEndpoint/${user.uid}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          ...updates,
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update user profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  // Check if user exists in MongoDB
  static Future<bool> checkUserExistsInMongoDB() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse('$_baseUrl$_usersEndpoint/${user.uid}/exists'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Delete MongoDB user profile (when Firebase user is deleted)
  static Future<void> deleteMongoUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      final token = await user.getIdToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl$_usersEndpoint/${user.uid}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting user profile: $e');
    }
  }

  // Get user role from MongoDB
  static Future<String> getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'student';

    try {
      final profile = await getMongoUserProfile();
      return profile['role'] ?? 'student';
    } catch (e) {
      return 'student';
    }
  }

  // Update user role in MongoDB
  static Future<void> updateUserRole(String role) async {
    await updateMongoUserProfile({'role': role});
  }

  // Verify Firebase token with MongoDB backend
  static Future<bool> verifyFirebaseToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final token = await user.getIdToken();
      final response = await http.post(
        Uri.parse('$_baseUrl$_authEndpoint/verify'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Handle user sign-in flow
  static Future<void> handleUserSignIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final exists = await checkUserExistsInMongoDB();
      if (!exists) {
        await syncUserWithMongoDB();
      }
    } catch (e) {
      // Log error but don't prevent sign-in
      debugPrint('Error handling user sign-in sync: $e');
    }
  }

  // Handle user sign-out
  static Future<void> handleUserSignOut() async {
    // Any cleanup needed when user signs out
    // Currently just clears local state
  }
}
