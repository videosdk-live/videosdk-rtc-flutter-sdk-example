import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:videosdk_flutter_example/utils/spacer.dart';

import '../../constants/colors.dart';
import 'meeting_action_button.dart';

// Meeting ActionBar
class MeetingActionBar extends StatelessWidget {
  // control states
  final bool isMicEnabled, isCamEnabled, isScreenShareEnabled, isRecordingOn;

  // callback functions
  final void Function() onCallEndButtonPressed,
      onCallLeaveButtonPressed,
      onMicButtonPressed,
      onCameraButtonPressed,
      onChatButtonPressed;

  final void Function(String) onMoreOptionSelected;

  final void Function(TapDownDetails) onSwitchMicButtonPressed;
  const MeetingActionBar({
    Key? key,
    required this.isMicEnabled,
    required this.isCamEnabled,
    required this.isScreenShareEnabled,
    required this.isRecordingOn,
    required this.onCallEndButtonPressed,
    required this.onCallLeaveButtonPressed,
    required this.onMicButtonPressed,
    required this.onSwitchMicButtonPressed,
    required this.onCameraButtonPressed,
    required this.onMoreOptionSelected,
    required this.onChatButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PopupMenuButton(
              position: PopupMenuPosition.under,
              padding: EdgeInsets.all(0),
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: red),
                  color: red,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.call_end,
                  size: 30,
                ),
              ),
              offset: Offset(0, -185),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) => {
                    if (value == "leave")
                      onCallLeaveButtonPressed()
                    else if (value == "end")
                      onCallEndButtonPressed()
                  },
              itemBuilder: (context) => <PopupMenuEntry>[
                    _buildMeetingPoupItem(
                      "leave",
                      "Leave",
                      "Only you will leave the call",
                      SvgPicture.asset("assets/ic_leave.svg"),
                    ),
                    const PopupMenuDivider(),
                    _buildMeetingPoupItem(
                      "end",
                      "End",
                      "End call for all participants",
                      SvgPicture.asset("assets/ic_end.svg"),
                    ),
                  ]),

          // Mic Control
          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor: isMicEnabled ? primaryColor : Colors.white,
            onTap: onMicButtonPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white30),
                color: isMicEnabled ? primaryColor : Colors.white,
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    isMicEnabled ? Icons.mic : Icons.mic_off,
                    size: 30,
                    color: isMicEnabled ? Colors.white : primaryColor,
                  ),
                  GestureDetector(
                      onTapDown: (details) =>
                          {onSwitchMicButtonPressed(details)},
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: isMicEnabled ? Colors.white : primaryColor,
                        ),
                      )),
                ],
              ),
            ),
          ),

          // Camera Control
          MeetingActionButton(
            onPressed: onCameraButtonPressed,
            icon: isCamEnabled ? Icons.videocam : Icons.videocam_off,
          ),

          MeetingActionButton(
            onPressed: onChatButtonPressed,
            icon: Icons.comment,
          ),

          // More options
          PopupMenuButton(
              position: PopupMenuPosition.under,
              padding: EdgeInsets.all(0),
              color: black700,
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
                  // color: red,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.more_vert,
                  size: 30,
                ),
              ),
              offset: Offset(0, -250),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) => {onMoreOptionSelected(value.toString())},
              itemBuilder: (context) => <PopupMenuEntry>[
                    _buildMeetingPoupItem(
                      "recording",
                      isRecordingOn ? "Stop Recording" : "Start Recording",
                      null,
                      SvgPicture.asset("assets/ic_recording.svg"),
                    ),
                    const PopupMenuDivider(),
                    _buildMeetingPoupItem(
                      "screenshare",
                      isScreenShareEnabled
                          ? "Stop Screen Share"
                          : "Start Screen Share",
                      null,
                      SvgPicture.asset("assets/ic_screen_share.svg"),
                    ),
                    const PopupMenuDivider(),
                    _buildMeetingPoupItem(
                      "participants",
                      "Participants",
                      null,
                      SvgPicture.asset("assets/ic_participants.svg"),
                    ),
                  ]),
        ],
      ),
    );
  }

  DropdownMenuItem<String> _buildMeetingDropDownItem(
      String value, String title, String? description, Widget leadingIcon) {
    return DropdownMenuItem(
      value: value,
      child: Row(children: [
        leadingIcon,
        const HorizontalSpacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            if (description != null)
              Text(
                description,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: black400),
              )
          ],
        )
      ]),
    );
  }

  PopupMenuItem<dynamic> _buildMeetingPoupItem(
      String value, String title, String? description, Widget leadingIcon) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        leadingIcon,
        const HorizontalSpacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            if (description != null)
              Text(
                description,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: black400),
              )
          ],
        )
      ]),
    );
  }
}
