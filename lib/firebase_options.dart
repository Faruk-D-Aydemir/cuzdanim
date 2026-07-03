// Firebase — deneme-app-935b6 projesi

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'firebase_web_app_id.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Bu platform için Firebase yapılandırılmadı. '
          'Samsung telefonda çalıştır: flutter run',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMbl9c5ig9sOoWwYYHhLVSb-niIdOeJ-I',
    appId: '1:927025131625:android:e36b121f01e048744d32f8',
    messagingSenderId: '927025131625',
    projectId: 'deneme-app-935b6',
    authDomain: 'deneme-app-935b6.firebaseapp.com',
    storageBucket: 'deneme-app-935b6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAMbl9c5ig9sOoWwYYHhLVSb-niIdOeJ-I',
    appId: '1:927025131625:android:e36b121f01e048744d32f8',
    messagingSenderId: '927025131625',
    projectId: 'deneme-app-935b6',
    storageBucket: 'deneme-app-935b6.firebasestorage.app',
    iosBundleId: 'com.example.denemeApp',
  );

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: 'AIzaSyAMbl9c5ig9sOoWwYYHhLVSb-niIdOeJ-I',
        appId: firebaseWebAppId ??
            '1:927025131625:android:e36b121f01e048744d32f8',
        messagingSenderId: '927025131625',
        projectId: 'deneme-app-935b6',
        authDomain: 'deneme-app-935b6.firebaseapp.com',
        storageBucket: 'deneme-app-935b6.firebasestorage.app',
      );

  static bool get isWebMisconfigured =>
      kIsWeb &&
      (firebaseWebAppId == null || firebaseWebAppId!.contains(':android:'));

  static bool get isConfigured => !isWebMisconfigured;
}
