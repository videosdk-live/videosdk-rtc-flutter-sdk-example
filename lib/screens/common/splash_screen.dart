import 'dart:async';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'join_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const JoinScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Center(
            child: Image.asset('assets/logo.png'),
          ),
          Positioned(
            bottom: ResponsiveValue<double>(context, conditionalValues: [
              const Condition.equals(name: MOBILE, value: 40),
              const Condition.largerThan(name: MOBILE, value: 0),
            ]).value!,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/videosdk_text.png',
              fit: BoxFit.scaleDown,
              scale: 4,
            ),
          )
        ],
      ),
    );
  }
}
