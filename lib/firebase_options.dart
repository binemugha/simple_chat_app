// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyD5sd6Slvo2_q-FpVIVaaAc8vbPFsvwwMo',
    appId: '1:22676159994:web:5e67ab68d7debfdb3b7843',
    messagingSenderId: '22676159994',
    projectId: 'simple-chat-app-8a3d8',
    authDomain: 'simple-chat-app-8a3d8.firebaseapp.com',
    storageBucket: 'simple-chat-app-8a3d8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBHe34gSzbUNe-gNw5Tb4sp4IhAcTUcwgk',
    appId: '1:22676159994:ios:7247e9ee045b68793b7843',
    messagingSenderId: '22676159994',
    projectId: 'simple-chat-app-8a3d8',
    storageBucket: 'simple-chat-app-8a3d8.firebasestorage.app',
    iosBundleId: 'com.example.simpleChatApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBHe34gSzbUNe-gNw5Tb4sp4IhAcTUcwgk',
    appId: '1:22676159994:ios:7247e9ee045b68793b7843',
    messagingSenderId: '22676159994',
    projectId: 'simple-chat-app-8a3d8',
    storageBucket: 'simple-chat-app-8a3d8.firebasestorage.app',
    iosBundleId: 'com.example.simpleChatApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD5sd6Slvo2_q-FpVIVaaAc8vbPFsvwwMo',
    appId: '1:22676159994:web:30460f0c65eeeb953b7843',
    messagingSenderId: '22676159994',
    projectId: 'simple-chat-app-8a3d8',
    authDomain: 'simple-chat-app-8a3d8.firebaseapp.com',
    storageBucket: 'simple-chat-app-8a3d8.firebasestorage.app',
  );
}
