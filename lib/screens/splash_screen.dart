import 'dart:async';
import 'package:flutter/material.dart';
import 'startup_screen.dart';

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
          builder: (context) => const StartupScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(10, 13, 44, 1),
      body: Stack(
        children: [
          Center(
            child: Image.asset('assets/logo.png'),
          ),
          Positioned(
            bottom: 40,
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
