import 'package:flutter/material.dart';

import '../../constants/colors.dart';

// Action Button
class MeetingActionButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData icon;
  final Color backgroundColor, iconColor;
  final double radius;

  const MeetingActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = secondaryColor,
    this.iconColor = Colors.white,
    this.radius = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white30),
        color: backgroundColor,
      ),
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onPressed,
        child: Icon(
          icon,
          size: 30,
          color: iconColor,
        ),
      ),
    );
  }
}
