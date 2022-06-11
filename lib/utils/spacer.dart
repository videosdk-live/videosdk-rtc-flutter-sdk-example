import 'package:flutter/material.dart';

// Vertical Spacer
class VerticalSpacer extends StatelessWidget {
  final double height;
  const VerticalSpacer([this.height = 8.0, Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

// Horizontal Spacer
class HorizontalSpacer extends StatelessWidget {
  final double width;
  const HorizontalSpacer([this.width = 8.0, Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}
