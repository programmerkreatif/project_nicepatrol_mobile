import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyA4r2OB3e2_o9kmvYJbQ08Yp-ceGHJ2EWw",
      appId: "1:36435104271:android:1d05be9b5cbd5072bf897a",
      messagingSenderId: "36435104271",
      projectId: "nicepatrol-546f7",
      storageBucket: "nicepatrol-546f7.firebasestorage.app",
    );
  }
}
