// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:placepro/Service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  
  late TextEditingController _nameController;
  late TextEditingController _registerNumberController;
  late TextEditingController _yearController;
  late TextEditingController _departmentController;
  late TextEditingController _sectionController;
  late TextEditingController _aboutMeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _registerNumberController = TextEditingController();
    _yearController = TextEditingController();
    _departmentController = TextEditingController();
    _sectionController = TextEditingController();
    _aboutMeController = TextEditingController();
    
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registerNumberController.dispose();
    _yearController.dispose();
    _departmentController.dispose();
    _sectionController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        
        if (mounted) {
          setState(() {
            _nameController.text = userData['name'] ?? '';
            _registerNumberController.text = userData['registerNumber'] ?? '';
            _yearController.text = userData['year'] ?? '';
            _departmentController.text = userData['department'] ?? '';
            _sectionController.text = userData['section'] ?? '';
            _aboutMeController.text = userData['aboutMe'] ?? '';
          });
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'name': _nameController.text.trim(),
            'registerNumber': _registerNumberController.text.trim(),
            'year': _yearController.text.trim(),
            'department': _departmentController.text.trim(),
            'section': _sectionController.text.trim(),
            'aboutMe': _aboutMeController.text.trim(),
          });
          
          if (!mounted) return;
          setState(() {
            _isEditing = false;
            _isLoading = false;
          });
          
          if (context.mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
  }

  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navContext = Navigator.of(context);
              final authService = Provider.of<AuthService>(context, listen: false);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              navContext.pop();
              setState(() {
                _isLoading = true;
              });

              try {
                await authService.deleteAccount();
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error deleting account: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isLoading
                ? null
                : () {
                    if (_isEditing) {
                      _updateProfile();
                    } else {
                      setState(() {
                        _isEditing = true;
                      });
                    }
                  },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Picture
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/images/default_avatar.png'),
                    ),
                    const SizedBox(height: 24),
                    
                    // User Info Fields
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _registerNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Register Number',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your register number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _yearController,
                            decoration: const InputDecoration(
                              labelText: 'Year',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            enabled: _isEditing,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Year';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _sectionController,
                            decoration: const InputDecoration(
                              labelText: 'Section',
                              prefixIcon: Icon(Icons.category),
                              border: OutlineInputBorder(),
                            ),
                            enabled: _isEditing,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Section';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _departmentController,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        prefixIcon: Icon(Icons.school),
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your department';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _aboutMeController,
                      decoration: const InputDecoration(
                        labelText: 'About Me',
                        prefixIcon: Icon(Icons.info),
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Logout'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _deleteAccount,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Delete Account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}