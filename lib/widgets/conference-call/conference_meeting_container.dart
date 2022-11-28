import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:videosdk/videosdk.dart';

class ConferenceMeetingContainer extends StatefulWidget {
  final Room meeting;
  const ConferenceMeetingContainer({Key? key, required this.meeting})
      : super(key: key);
  @override
  State<ConferenceMeetingContainer> createState() =>
      _ConferenceMeetingContainerState();
}

class _ConferenceMeetingContainerState
    extends State<ConferenceMeetingContainer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
