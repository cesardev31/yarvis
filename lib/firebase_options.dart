// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  static String get API_KEY => dotenv.env['API_KEY'] ?? '';

  static FirebaseOptions android = FirebaseOptions(
    apiKey: API_KEY,
    appId: '1:51570400083:android:bb33a59b456af6a1989fa6',
    messagingSenderId: '51570400083',
    projectId: 'yarvis-ia-chat',
    storageBucket: 'yarvis-ia-chat.firebasestorage.app',
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: API_KEY,
    appId: '1:51570400083:ios:fec1467eacfed0dd989fa6',
    messagingSenderId: '51570400083',
    projectId: 'yarvis-ia-chat',
    storageBucket: 'yarvis-ia-chat.firebasestorage.app',
    iosBundleId: 'com.example.yarvis',
  );
}
