// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Web configuration
    return const FirebaseOptions(
      apiKey: 'AIzaSyA_dD1gDd-zLKM_MBxMPIQdu9NXgg7FqIk',
      appId: '1:792008558099:web:6d7460aa27d190c26ce1e6',
      messagingSenderId: '792008558099',
      projectId: 'place-pro-569ed',
      authDomain: 'place-pro-569ed.firebaseapp.com',
      storageBucket: 'place-pro-569ed.appspot.com',
      measurementId: 'G-ZCMKP3TMX0',
    );
  }
}
