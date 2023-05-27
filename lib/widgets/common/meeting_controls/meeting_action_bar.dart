import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/utils/spacer.dart';

import '../../../constants/colors.dart';

// Meeting ActionBar
class MeetingActionBar extends StatelessWidget {
  // control states
  final bool isMicEnabled, isCamEnabled, isScreenShareEnabled;
  final String recordingState;

  // callback functions
  final void Function() onCallEndButtonPressed,
      onCallLeaveButtonPressed,
      onMicButtonPressed,
      onCameraButtonPressed,
      onChatButtonPressed;

  final void Function(String) onMoreOptionSelected;

  final Room meeting;

  const MeetingActionBar({
    Key? key,
    required this.meeting,
    required this.isMicEnabled,
    required this.isCamEnabled,
    required this.isScreenShareEnabled,
    required this.recordingState,
    required this.onCallEndButtonPressed,
    required this.onCallLeaveButtonPressed,
    required this.onMicButtonPressed,
    required this.onCameraButtonPressed,
    required this.onMoreOptionSelected,
    required this.onChatButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: PopupMenuButton(
                position: PopupMenuPosition.under,
                padding: const EdgeInsets.all(0),
                color: black700,
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: red),
                      color: red,
                      shape: BoxShape.rectangle),
                  child: const Icon(
                    Icons.call_end,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                offset: const Offset(0, -185),
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
                        leadingIcon: SvgPicture.asset("assets/ic_leave.svg"),
                      ),
                      const PopupMenuDivider(),
                      _buildMeetingPoupItem(
                        "end",
                        "End",
                        "End call for all participants",
                        leadingIcon: SvgPicture.asset("assets/ic_end.svg"),
                      ),
                    ]),
          ),

          // Mic Control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TouchRippleEffect(
              borderRadius: BorderRadius.circular(12),
              rippleColor: isMicEnabled ? primaryColor : Colors.white,
              onTap: onMicButtonPressed,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
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
                    PopupMenuButton(
                      position: PopupMenuPosition.over,
                      padding: const EdgeInsets.all(0),
                      color: black700,
                      offset: getOutputAudioList() != null ? const Offset(0, -300) : const Offset(0, -190),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: isMicEnabled ? Colors.white : primaryColor,
                      ),
                      onSelected: (value) {
                        if (value == 'label') {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please select device')));
                        } else {
                          MediaDeviceInfo deviceInfo = value as MediaDeviceInfo;
                          if (kIsWeb || Platform.isMacOS || Platform.isWindows) {
                            if (deviceInfo.kind == "audiooutput") {
                              meeting.switchAudioDevice(deviceInfo);
                            } else if (deviceInfo.kind == "audioinput") {
                              meeting.changeMic(deviceInfo);
                            }
                          } else {
                            meeting.switchAudioDevice(deviceInfo);
                          }
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          _buildMeetingPoupItem(
                              'label',
                              kIsWeb || Platform.isMacOS || Platform.isWindows
                                  ? 'Microphones'
                                  : 'Audio Devices',
                              null,
                              leadingIcon: const Icon(
                                Icons.mic,
                                color: Color.fromARGB(255, 77, 75, 75),
                              ),
                              textColor: const Color.fromARGB(255, 77, 75, 75)),
                          PopupMenuItem(
                            child: Column(
                                children: getMicList()
                                    .map(
                                      (e) =>
                                          _buildMeetingPoupItem(e, e.label, null),
                                    )
                                    .toList()),
                          ),
                          if (getOutputAudioList() != null)
                            _buildMeetingPoupItem('label', 'Speakers', null,
                                leadingIcon: const Icon(
                                  Icons.volume_up,
                                  color: Color.fromARGB(255, 77, 75, 75),
                                ),
                                textColor: const Color.fromARGB(255, 77, 75, 75)),
                          if (getOutputAudioList() != null)
                            PopupMenuItem(
                              child: Column(
                                  children: getOutputAudioList()!
                                      .map(
                                        (e) => _buildMeetingPoupItem(
                                            e, e.label, null),
                                      )
                                      .toList()),
                            )
                        ];
                      },
                    )
                  ],
                ),
              ),
            ),
          ),

          // Camera Control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TouchRippleEffect(
              borderRadius: BorderRadius.circular(12),
              rippleColor: primaryColor,
              onTap: onCameraButtonPressed,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
                  color: isCamEnabled ? primaryColor : Colors.white,
                ),
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  isCamEnabled
                      ? "assets/ic_video.svg"
                      : "assets/ic_video_off.svg",
                  width: 26,
                  height: 26,
                  color: isCamEnabled ? Colors.white : primaryColor,
                ),
              ),
            ),
          ),

          Padding(
           padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TouchRippleEffect(
              borderRadius: BorderRadius.circular(12),
              rippleColor: primaryColor,
              onTap: onChatButtonPressed,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
                  color: primaryColor,
                ),
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  "assets/ic_chat.svg",
                  width: 26,
                  height: 26,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // More options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: PopupMenuButton(
                position: PopupMenuPosition.under,
                padding: const EdgeInsets.all(0),
                color: black700,
                icon: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: secondaryColor),
                      shape: BoxShape.rectangle
                      // color: red,
                      ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: const Icon(
                    Icons.more_vert,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                offset: const Offset(0, -250),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) => {onMoreOptionSelected(value.toString())},
                itemBuilder: (context) => <PopupMenuEntry>[
                      _buildMeetingPoupItem(
                        "recording",
                        recordingState == "RECORDING_STARTED"
                            ? "Stop Recording"
                            : recordingState == "RECORDING_STARTING"
                                ? "Recording is starting"
                                : "Start Recording",
                        null,
                        leadingIcon: SvgPicture.asset("assets/ic_recording.svg"),
                      ),
                      const PopupMenuDivider(),
                      _buildMeetingPoupItem(
                        "screenshare",
                        isScreenShareEnabled
                            ? "Stop Screen Share"
                            : "Start Screen Share",
                        null,
                        leadingIcon:
                            SvgPicture.asset("assets/ic_screen_share.svg"),
                      ),
                      const PopupMenuDivider(),
                      _buildMeetingPoupItem(
                        "participants",
                        "Participants",
                        null,
                        leadingIcon:
                            SvgPicture.asset("assets/ic_participants.svg"),
                      ),
                    ]),
          ),
        ],
      ),
    );
  }

  List<MediaDeviceInfo> getMicList() {
    if (kIsWeb || Platform.isMacOS || Platform.isWindows) {
      return meeting.getMics();
    } else {
      return meeting.getAudioOutputDevices();
    }
  }

  List<MediaDeviceInfo>? getOutputAudioList() {
    if (kIsWeb || Platform.isMacOS || Platform.isWindows) {
      return meeting.getAudioOutputDevices();
    } else {
      return null;
    }
  }

  PopupMenuItem<dynamic> _buildMeetingPoupItem(
      dynamic value, String title, String? description,
      {Widget? leadingIcon, Color? textColor}) {
    return PopupMenuItem(
      value: value,
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: Row(children: [
        leadingIcon ?? const Center(),
        const HorizontalSpacer(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Colors.white),
            ),
            if (description != null) const VerticalSpacer(4),
            if (description != null)
              Text(
                description,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500, color: black400),
              )
          ],
        )
      ]),
    );
  }
}
