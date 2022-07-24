// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    // ignore: missing_enum_constant_in_switch
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
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyATVjrfDqUlrUmpS1uQUPUBNC5eCLO5D6U',
    appId: '1:444875794216:android:0cf772ffb7fae38439d21d',
    messagingSenderId: '444875794216',
    projectId: 'videosdk-codesample-analytics',
    storageBucket: 'videosdk-codesample-analytics.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBdD-o56meOk8LMVbZABWVZvFH_JOFJ0AM',
    appId: '1:444875794216:ios:bc1305767eb2ca6339d21d',
    messagingSenderId: '444875794216',
    projectId: 'videosdk-codesample-analytics',
    storageBucket: 'videosdk-codesample-analytics.appspot.com',
    iosClientId:
        '444875794216-n0fcaoukjij002s72734vonk62924ftr.apps.googleusercontent.com',
    iosBundleId: 'live.videosdk.flutter.example',
  );
}
