// lib/services/auth_service.dart
// Authentication service for PlacePro app
// Handles Firebase Auth integration with Firestore user management
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  String? _role;
  
  User? get user => _user;
  String? get role => _role;
  
  bool get isAdmin => _role == 'admin';
  bool get isAuthenticated => _user != null;
  
  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _getUserRole(user.uid);
      } else {
        _role = null;
      }
      notifyListeners();
    });
  }
  
  Future<void> _getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _role = userDoc.get('role');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error getting user role: $e');
    }
  }
  
  Future<String?> signIn(String email, String password) async {
    try {
      // Check if email ends with @saec.ac.in
      if (!email.endsWith('@saec.ac.in')) {
        return 'Only SAEC email addresses are allowed';
      }
      
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Get user role
      await _getUserRole(result.user!.uid);
      
      return null; // Return null if no error
    } on FirebaseAuthException catch (e) {
      // Provide clearer error including code
      final code = e.code.isNotEmpty ? e.code : 'auth/unknown';
      final msg = e.message ?? 'An unknown authentication error occurred.';
      return '$code: $msg';
    } catch (e) {
      return 'auth/unexpected: An error occurred: $e';
    }
  }
  
  Future<String?> signUp(String email, String password, String name, String registerNumber, 
                         String year, String department, String section) async {
    try {
      // Check if email ends with @saec.ac.in
      if (!email.endsWith('@saec.ac.in')) {
        return 'Only SAEC email addresses are allowed';
      }
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'registerNumber': registerNumber,
        'year': year,
        'department': department,
        'section': section,
        'aboutMe': '',
        'role': 'student', // Default role is student
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Set role
      _role = 'student';
      
      return null; // Return null if no error
    } on FirebaseAuthException catch (e) {
      final code = e.code.isNotEmpty ? e.code : 'auth/unknown';
      final msg = e.message ?? 'An unknown authentication error occurred.';
      return '$code: $msg';
    } catch (e) {
      return 'auth/unexpected: An error occurred: $e';
    }
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  Future<void> deleteAccount() async {
    if (_user != null) {
      // Delete user document from Firestore
      await _firestore.collection('users').doc(_user!.uid).delete();
      
      // Delete user from Firebase Auth
      await _user!.delete();
    }
  }
  
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).update(data);
    }
  }
}