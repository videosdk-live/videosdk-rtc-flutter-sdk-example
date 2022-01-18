import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ui/constants/colors.dart';
import 'ui/screens/startup_screen.dart';
import 'ui/utils/navigator_key.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VideoSDK Flutter Example',
      theme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme().copyWith(
          color: PRIMARY_COLOR,
        ),
        primaryColor: PRIMARY_COLOR,
        backgroundColor: SECONDARY_COLOR,
      ),
      home: const StartupScreen(),
      navigatorKey: navigatorKey,
    );
  }
}
