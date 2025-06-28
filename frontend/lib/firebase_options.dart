import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for this platform.',
    );
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: const String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'AIzaSyA76JE40QbT8NHvynBsFSIgD_Nzk1zOqog'),
    appId: const String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '1:156065435185:web:ccf5234c23cb4441134f10'),
    messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '156065435185'),
    projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'engineeringu'),
    authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: 'engineeringu.firebaseapp.com'),
    storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'engineeringu.firebasestorage.app'),
    databaseURL: const String.fromEnvironment('FIREBASE_DATABASE_URL', defaultValue: 'https://engineeringu-default-rtdb.firebaseio.com'),
    measurementId: null,
  );
}
