import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError('Only web supported.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB73YgI4g1DQMU_finohQUjd5q68asrDGU',
    appId: '1:332395737612:web:679e6a4436da1cc9413429',
    messagingSenderId: '332395737612',
    projectId: 'smart-traffic-sudan',
    authDomain: 'smart-traffic-sudan.firebaseapp.com',
    storageBucket: 'smart-traffic-sudan.firebasestorage.app',
    measurementId: 'G-HBRVC86D20',
  );
}
