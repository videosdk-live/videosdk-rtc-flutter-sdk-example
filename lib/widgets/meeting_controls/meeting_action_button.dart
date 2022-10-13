import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';

// Action Button
class MeetingActionButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData icon;
  final Color backgroundColor, iconColor, borderColor;
  final double radius, iconSize;
  final Widget? trailingWidget;

  const MeetingActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = primaryColor,
    this.borderColor = secondaryColor,
    this.iconColor = Colors.white,
    this.radius = 12,
    this.iconSize = 30,
    this.trailingWidget = null,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TouchRippleEffect(
      borderRadius: BorderRadius.circular(radius),
      rippleColor: backgroundColor,
      onTap: onPressed,
      child: Container(
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
