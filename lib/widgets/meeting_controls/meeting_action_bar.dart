import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import 'meeting_action_button.dart';

// Meeting ActionBar
class MeetingActionBar extends StatelessWidget {
  // control states
  final bool isMicEnabled, isWebcamEnabled;

  // callback functions
  final void Function() onCallEndButtonPressed,
      onMicButtonPressed,
      onWebcamButtonPressed,
      onSwitchCameraButtonPressed,
      onMoreButtonPressed;

  const MeetingActionBar({
    Key? key,
    required this.isMicEnabled,
    required this.isWebcamEnabled,
    required this.onCallEndButtonPressed,
    required this.onMicButtonPressed,
    required this.onWebcamButtonPressed,
    required this.onSwitchCameraButtonPressed,
    required this.onMoreButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Theme.of(context).backgroundColor,
      child: Row(
        children: [
          // Call End Control
          Expanded(
            child: MeetingActionButton(
              backgroundColor: Colors.red,
              onPressed: onCallEndButtonPressed,
              icon: Icons.call_end,
            ),
          ),

          // Mic Control
          Expanded(
            child: MeetingActionButton(
              onPressed: onMicButtonPressed,
              backgroundColor: isMicEnabled
                  ? secondaryColor
                  : secondaryColor.withOpacity(0.8),
              icon: isMicEnabled ? Icons.mic : Icons.mic_off,
            ),
          ),

          // Webcam Control
          Expanded(
            child: MeetingActionButton(
              onPressed: onWebcamButtonPressed,
              backgroundColor: isWebcamEnabled
                  ? secondaryColor
                  : secondaryColor.withOpacity(0.8),
              icon: isWebcamEnabled ? Icons.videocam : Icons.videocam_off,
            ),
          ),

          // Webcam Switch Control
          Expanded(
            child: MeetingActionButton(
              backgroundColor: isWebcamEnabled
                  ? secondaryColor
                  : secondaryColor.withOpacity(0.8),
              onPressed: isWebcamEnabled ? onSwitchCameraButtonPressed : null,
              icon: Icons.cameraswitch,
            ),
          ),

          // More options
          Expanded(
            child: MeetingActionButton(
              backgroundColor: secondaryColor.withOpacity(0.8),
              onPressed: onMoreButtonPressed,
              icon: Icons.more_vert,
            ),
          ),
        ],
      ),
    );
  }
}
