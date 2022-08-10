import 'dart:io';

import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import 'meeting_action_button.dart';

// Meeting ActionBar
class MeetingActionBar extends StatelessWidget {
  // control states
  final bool isMicEnabled,
      isCamEnabled,
      isScreenShareEnabled,
      isScreenShareButtonDisabled;

  // callback functions
  final void Function() onCallEndButtonPressed,
      onMicButtonPressed,
      onCameraButtonPressed,
      onSwitchCameraButtonPressed,
      onMoreButtonPressed,
      onScreenShareButtonPressed;

  const MeetingActionBar({
    Key? key,
    required this.isMicEnabled,
    required this.isCamEnabled,
    required this.isScreenShareEnabled,
    required this.isScreenShareButtonDisabled,
    required this.onCallEndButtonPressed,
    required this.onMicButtonPressed,
    required this.onCameraButtonPressed,
    required this.onSwitchCameraButtonPressed,
    required this.onScreenShareButtonPressed,
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
              backgroundColor:
                  isMicEnabled ? hoverColor : secondaryColor.withOpacity(0.8),
              icon: isMicEnabled ? Icons.mic : Icons.mic_off,
            ),
          ),

          // Camera Control
          Expanded(
            child: MeetingActionButton(
              onPressed: onCameraButtonPressed,
              backgroundColor:
                  isCamEnabled ? hoverColor : secondaryColor.withOpacity(0.8),
              icon: isCamEnabled ? Icons.videocam : Icons.videocam_off,
            ),
          ),

          // Camera Switch Control
          Expanded(
            child: MeetingActionButton(
              backgroundColor: secondaryColor.withOpacity(0.8),
              onPressed: isCamEnabled ? onSwitchCameraButtonPressed : null,
              icon: Icons.cameraswitch,
            ),
          ),

          // ScreenShare Control
          if (Platform.isAndroid)
            Expanded(
              child: MeetingActionButton(
                backgroundColor: isScreenShareEnabled
                    ? hoverColor
                    : secondaryColor.withOpacity(0.8),
                onPressed: isScreenShareButtonDisabled
                    ? null
                    : onScreenShareButtonPressed,
                icon: isScreenShareEnabled
                    ? Icons.screen_share
                    : Icons.stop_screen_share,
                iconColor:
                    isScreenShareButtonDisabled ? Colors.white30 : Colors.white,
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
