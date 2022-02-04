import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';

// Action Button
class MeetingActionButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData icon;
  final Color backgroundColor, iconColor;
  final double radius, iconSize;

  const MeetingActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = secondaryColor,
    this.iconColor = Colors.white,
    this.radius = 10,
    this.iconSize = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TouchRippleEffect(
      borderRadius: BorderRadius.circular(radius),
      rippleColor: backgroundColor,
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white30),
          color: backgroundColor,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}
