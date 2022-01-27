import 'package:flutter/material.dart';

class MeetingActionButton extends StatelessWidget {
  final void Function() onClick;
  final IconData icon;
  final Color color;
  const MeetingActionButton({
    Key? key,
    required this.onClick,
    required this.icon,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: color,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 30,
        ),
      ),
    );
  }
}
