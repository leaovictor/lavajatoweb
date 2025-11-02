import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDJWXAnskXhC2-0aVbdk6kSZ8y7zh2Q0ns',
    appId: '1:136391405566:web:3277db47e3dc4670619aaf',
    messagingSenderId: '136391405566',
    projectId: 'lavajato-5944c',
    authDomain: 'lavajato-5944c.firebaseapp.com',
    storageBucket: 'lavajato-5944c.appspot.com',
    measurementId: 'G-ZHZ019XBV7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJWXAnskXhC2-0aVbdk6kSZ8y7zh2Q0ns',
    appId: '1:136391405566:android:3277db47e3dc4670619aaf',
    messagingSenderId: '136391405566',
    projectId: 'lavajato-5944c',
    storageBucket: 'lavajato-5944c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDJWXAnskXhC2-0aVbdk6kSZ8y7zh2Q0ns',
    appId: '1:136391405566:ios:3277db47e3dc4670619aaf',
    messagingSenderId: '136391405566',
    projectId: 'lavajato-5944c',
    storageBucket: 'lavajato-5944c.appspot.com',
    iosBundleId: 'com.example.lavajato',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDJWXAnskXhC2-0aVbdk6kSZ8y7zh2Q0ns',
    appId: '1:136391405566:ios:3277db47e3dc4670619aaf',
    messagingSenderId: '136391405566',
    projectId: 'lavajato-5944c',
    storageBucket: 'lavajato-5944c.appspot.com',
    iosBundleId: 'com.example.lavajato',
  );
}