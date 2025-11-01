import 'package:flutter/material.dart';
import 'package:placepro/screens/home_screen.dart';
import 'package:placepro/screens/login_screen.dart'; 
import 'package:provider/provider.dart';
import 'package:placepro/Service/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    if (authService.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}