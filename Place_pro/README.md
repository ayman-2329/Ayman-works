# PlacePro - SAEC Placement App

A comprehensive placement application for SAEC students, providing access to job opportunities, aptitude tests, and placement resources.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.13.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.1.0-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-11.7.7-orange.svg)](https://firebase.google.com/)

## 🚀 Features

### Core Features
- **User Authentication** - Secure login/signup with email/password and social providers
- **Job/Drive Listings** - Browse and apply to current job openings and placement drives
- **Aptitude Tests** - Practice with a variety of aptitude questions and mock tests
- **Resume Builder** - Create and manage professional resumes
- **Admin Dashboard** - Manage content, users, and applications
- **Push Notifications** - Stay updated with real-time notifications
- **Analytics** - Track user engagement and app performance

### AI-Powered Features
- **Smart Chatbot** - AI-powered career guidance and query resolution
- **Daily Tips** - AI-generated daily tips for career development
- **Personalized Recommendations** - Smart job and resource recommendations
- **Interview Preparation** - AI-assisted mock interviews and feedback

## � Documentation

- [Developer Guide](docs/DEVELOPER_GUIDE.md) - Comprehensive guide for developers
- [AI Backend Documentation](docs/AI_BACKEND.md) - Setup and usage guide for the AI backend

## �📋 Prerequisites

- Flutter SDK (>=3.13.0)
- Dart SDK (>=3.1.0)
- Android Studio / Xcode (for building the app)
- Java JDK 11 or later
- Firebase project (for backend services)
- Node.js (for backend server)
- Python 3.8+ (for AI backend)

## 🛠️ Project Structure

```
lib/
├── config/              # Configuration files
├── data/                # Mock data and test data
├── models/              # Data models
├── screens/             # App screens
│   ├── auth/            # Authentication screens
│   ├── admin/           # Admin screens
│   └── user/            # User-facing screens
├── services/            # Business logic and API services
├── utils/               # Utilities and helpers
└── widgets/             # Reusable widgets
```

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/placepro.git
cd placepro/flutter_application_1
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download the configuration files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. Enable Authentication, Firestore, Storage, and Cloud Messaging in the Firebase Console

### 4. Set Up Backend

1. Navigate to the server directory:
   ```bash
   cd server
   ```
2. Install Node.js dependencies:
   ```bash
   npm install
   ```
3. Set up environment variables (copy `.env.example` to `.env` and update values)
4. Start the server:
   ```bash
   npm start
   ```

### 5. Run the App

```bash
# For development
flutter run -d <device_id>

# For production build
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🧪 Testing

### Unit Tests

```bash
flutter test
```

### Widget Tests

```bash
flutter test test/widget_test.dart
```

### Integration Tests

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

## 🏗️ Code Quality

### Linting

```bash
# Run linter
flutter analyze

# Fix common issues
flutter fix --apply
```

### Formatting

```bash
# Check formatting
flutter format --set-exit-if-changed .

# Format all Dart files
flutter format .
```

## 📦 Building for Release

### Android

1. Generate a keystore (if you don't have one):
   ```bash
   cd android
   .\generate_keystore.sh
   ```
   Follow the prompts to create a new keystore

2. Update `key.properties` with your keystore information

3. Build the app bundle:
   ```bash
   flutter build appbundle --release
   ```

### iOS

1. Update the bundle identifier in Xcode
2. Update the version and build number in Xcode
3. Build the archive:
   ```bash
   flutter build ios --release --no-codesign
   ```
4. Open Xcode and archive the app

## 📱 App Store Submission

### Prerequisites
- Apple Developer Account ($99/year)
- App store listing assets (screenshots, app icon, etc.)
- Privacy Policy URL
- App Store Connect account setup

### Submission Checklist

- [ ] Test the app thoroughly on multiple devices
- [ ] Update version and build numbers
- [ ] Prepare app store screenshots and description
- [ ] Complete privacy policy and app content questionnaire
- [ ] Submit for review

## 🤝 Contributing

1. Fork the repository
2. Create a new branch: `git checkout -b feature/your-feature`
3. Make your changes and commit them: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Submit a pull request

### Code Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- Firebase for the backend services
- All contributors who have helped improve this project

5. **App Content**
   - Privacy Policy URL
   - Target audience and content
   - Ads (if applicable)

6. **Pricing & Distribution**
   - Select countries/regions
   - Choose free or paid
   - Content guidelines compliance

7. **Review and Rollout**
   - Review all information
   - Start rollout to production (or use staged rollout)

## Post-Launch

- Monitor crash reports in Firebase Console
- Respond to user reviews
- Analyze user behavior with Google Analytics
- Plan for regular updates and bug fixes

## Scripts

- `scripts/build_release.ps1`: Build a release version of the app
- `scripts/analyze_size.ps1`: Analyze app size and performance
- `scripts/generate_changelog.ps1`: Generate changelog for new versions

## Troubleshooting

- **Build fails with signing errors**: Verify keystore configuration in `android/app/build.gradle`
- **App crashes on launch**: Check Firebase configuration and internet permissions
- **Large APK size**: Run `scripts/analyze_size.ps1` to identify large dependencies

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

For more information, see the [Flutter documentation](https://flutter.dev/docs).
