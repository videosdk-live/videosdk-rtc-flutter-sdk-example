import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/utils/spacer.dart';

class LocalScreenShareView extends StatelessWidget {
  final Function() onStopScreeenSharePressed;
  const LocalScreenShareView(
      {Key? key, required this.onStopScreeenSharePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SvgPicture.asset(
        "assets/ic_screen_share.svg",
        height: 40,
      ),
      const VerticalSpacer(20),
      const Text(
        "You are presenting to everyone",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      const VerticalSpacer(20),
      MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
          color: purple,
          child: const Text("Stop Presenting", style: TextStyle(fontSize: 16)),
          onPressed: onStopScreeenSharePressed)
    ]);
  }
}
