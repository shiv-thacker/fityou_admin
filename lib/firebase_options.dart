// ⚠️  IMPORTANT: Replace this file with the output of:
//    flutterfire configure
//
// Run: dart pub global activate flutterfire_cli
//      flutterfire configure
//
// This will auto-generate the correct Firebase options for your project.
// The file below is a PLACEHOLDER and will NOT work until you replace it.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError('Only web is supported in this admin panel.');
  }

  // 🔴 Replace ALL values below with your actual Firebase project config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDw-g6206e9TFkl XsoOB6RWN6QSmXMekvM",
    appId: "1:353357868258:web:11458bad4e48352d6e82bb",
    messagingSenderId: "353357868258",
    projectId: "outfit-app-534c5",
    authDomain: "outfit-app-534c5.firebaseapp.com",
    storageBucket: "outfit-app-534c5.firebasestorage.app",
    measurementId: "G-W0SKEYB9C7"
  );
}
