// File generated manually for Firebase configuration
// Based on google-services.json

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBsYWoCT-uQuCdml7KQXqnjf_BMTJ98goA',
    appId: '1:1030961201611:android:17dc48340a15f1ee51764e',
    messagingSenderId: '1030961201611',
    projectId: 'refinance-db7b2',
    storageBucket: 'refinance-db7b2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsYWoCT-uQuCdml7KQXqnjf_BMTJ98goA',
    appId: '1:1030961201611:ios:17dc48340a15f1ee51764e',
    messagingSenderId: '1030961201611',
    projectId: 'refinance-db7b2',
    storageBucket: 'refinance-db7b2.firebasestorage.app',
    iosBundleId: 'com.radjen.refinance',
  );
}
