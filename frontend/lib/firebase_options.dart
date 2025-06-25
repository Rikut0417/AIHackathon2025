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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA76JE40QbT8NHvynBsFSIgD_Nzk1zOqog',
    appId: '1:156065435185:web:ccf5234c23cb4441134f10',
    messagingSenderId: '156065435185',
    projectId: 'engineeringu',
    authDomain: 'engineeringu.firebaseapp.com',
    storageBucket: 'engineeringu.firebasestorage.app',
    measurementId: null,
  );
}
