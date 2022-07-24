import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:videosdk_flutter_example/firebase_options.dart';

import 'constants/colors.dart';
import 'navigator_key.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Run Flutter App
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Material App
    return MaterialApp(
      title: 'VideoSDK Flutter Example',
      theme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme().copyWith(
          color: primaryColor,
        ),
        primaryColor: primaryColor,
        backgroundColor: secondaryColor,
      ),
      home: const SplashScreen(),
      navigatorKey: navigatorKey,
    );
  }
}
