# PlacePro - Developer Guide

## Table of Contents
1. [Introduction](#1-introduction)
2. [Tech Stack](#2-tech-stack)
3. [Project Structure](#3-project-structure)
4. [Development Setup](#4-development-setup)
5. [Code Organization](#5-code-organization)
6. [State Management](#6-state-management)
7. [API Integration](#7-api-integration)
8. [Testing Strategy](#8-testing-strategy)
9. [Build & Deployment](#9-build--deployment)
10. [Troubleshooting](#10-troubleshooting)

## 1. Introduction

### 1.1 Overview
PlacePro is a comprehensive placement preparation platform for SAEC students, providing tools and resources for career development and job placement.

### 1.2 Key Features
- User authentication and profile management
- Placement drive listings and applications
- Aptitude test preparation
- Resume builder
- Admin dashboard
- Real-time notifications

## 2. Tech Stack

### 2.1 Core Technologies
- **Flutter 3.13.0** - UI framework
- **Dart 3.1.0** - Programming language
- **Firebase** - Backend services
- **Node.js** - Custom backend services

### 2.2 Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.32.0
  firebase_auth: ^4.20.0
  cloud_firestore: ^4.17.5
  provider: ^6.1.1
  http: ^1.2.0
  flutter_svg: ^2.0.10
  table_calendar: ^3.1.3
  intl: ^0.19.0
  url_launcher: ^6.2.5
  file_picker: ^6.2.1
```

## 3. Project Structure

### 3.1 Directory Layout
```
lib/
├── config/          # App configuration and constants
├── models/          # Data models
├── screens/         # UI screens
│   ├── admin/       # Admin interfaces
│   ├── auth/        # Authentication flows
│   └── user/        # User-facing screens
├── services/        # Business logic
├── utils/           # Helper functions
└── widgets/         # Reusable components
```

### 3.2 Important Files
- `main.dart` - Application entry point
- `firebase_options.dart` - Firebase configuration
- `pubspec.yaml` - Dependencies and metadata

## 4. Development Setup

### 4.1 Prerequisites
- Flutter SDK 3.13.0+
- Dart 3.1.0+
- Android Studio / Xcode
- Firebase account
- Node.js 16+

### 4.2 Getting Started
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   cd server && npm install
   ```
3. Set up Firebase:
   - Create a Firebase project
   - Add Android and iOS apps
   - Download config files
   - Enable required services

## 5. Code Organization

### 5.1 Feature Modules
Each feature follows this structure:
```
feature_name/
  ├── models/       # Data models
  ├── providers/    # State management
  ├── screens/      # UI components
  ├── services/     # Business logic
  └── widgets/      # Feature-specific widgets
```

### 5.2 Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables: `camelCase`
- Constants: `UPPER_SNAKE_CASE`

## 6. State Management

### 6.1 Provider Pattern
We use the Provider package for state management:
- `ChangeNotifier` for local state
- `ChangeNotifierProvider` for dependency injection
- `Consumer`/`context.watch` for listening to changes

### 6.2 State Management Example
```dart
class UserProvider with ChangeNotifier {
  User? _user;
  
  User? get user => _user;
  
  Future<void> loadUser() async {
    _user = await UserService.getCurrentUser();
    notifyListeners();
  }
}
```

## 7. API Integration

### 7.1 Firebase Services
- **Authentication**: User sign-in/sign-up
- **Firestore**: Data storage
- **Storage**: File uploads
- **Messaging**: Push notifications

### 7.2 Custom API Endpoints
```dart
class ApiService {
  static const String baseUrl = 'https://api.placepro.com';
  
  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    return _handleResponse(response);
  }
  
  // Additional methods...
}
```

## 8. Testing Strategy

### 8.1 Test Types
- **Unit tests**: Test individual functions/methods
- **Widget tests**: Test UI components
- **Integration tests**: Test complete features

### 8.2 Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/user_service_test.dart

# Run with coverage
flutter test --coverage
```

## 9. Build & Deployment

### 9.1 Build Commands
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build appbundle --release

# Web build
flutter build web --release
```

### 9.2 Deployment Checklist
- [ ] Update version in `pubspec.yaml`
- [ ] Run all tests
- [ ] Update changelog
- [ ] Create release notes
- [ ] Deploy to Firebase
- [ ] Submit to app stores

## 10. Troubleshooting

### 10.1 Common Issues
- **Firebase not initializing**: Check config files
- **Dependency conflicts**: Run `flutter pub upgrade`
- **Build failures**: Clean and rebuild
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

### 10.2 Getting Help
- Check existing issues
- Review Firebase documentation
- Contact the development team

---

For additional support, please contact the development team or open an issue in the repository.
