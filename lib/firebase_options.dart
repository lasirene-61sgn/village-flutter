import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not configured');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDv3LBRo2VqjldjEXDR1d7F40YDhkqGKsc', // Found in google-services.json -> current_key
    appId: '1:992878145244:android:e1e72a279f1f74b84bce19',   // Found in google-services.json -> mobilesdk_app_id
    messagingSenderId: '992878145244', // Found in google-services.json -> project_number
    projectId: 'jalore-d7dc0',       // Found in google-services.json -> project_id
    storageBucket: 'jalore-d7dc0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCZIQYP2mi5za5g0P96JTJC389KMTosLRs',
    appId: '1:1079245350998:ios:b274f520b99b414fd2b3f7',
    messagingSenderId: '1079245350998',
    projectId: 'test0-project-941b8',
    storageBucket: 'test0-project-941b8.firebasestorage.app',
    iosBundleId: 'com.srjt.chennai',
  );
}