import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/utils/api.dart';
import 'package:videosdk_flutter_example/utils/spacer.dart';
import 'package:videosdk_flutter_example/utils/toast.dart';
import 'package:videosdk_flutter_example/widgets/common/app_bar/recording_indicator.dart';
import 'package:videosdk_flutter_example/widgets/common/chat/chat_view.dart';
import 'package:videosdk_flutter_example/widgets/common/participant/participant_list.dart';
import 'package:videosdk_webrtc/flutter_webrtc.dart';
import 'package:videosdk_flutter_example/widgets/common/screen_share/screen_select_dialog.dart';

class WebMeetingAppBar extends StatefulWidget {
  final String token;
  final Room meeting;
  // control states
  final bool isMicEnabled,
      isCamEnabled,
      isLocalScreenShareEnabled,
      isRemoteScreenShareEnabled;
  final String recordingState;

  const WebMeetingAppBar({
    Key? key,
    required this.meeting,
    required this.token,
    required this.recordingState,
    required this.isMicEnabled,
    required this.isCamEnabled,
    required this.isLocalScreenShareEnabled,
    required this.isRemoteScreenShareEnabled,
  }) : super(key: key);

  @override
  State<WebMeetingAppBar> createState() => WebMeetingAppBarState();
}

class WebMeetingAppBarState extends State<WebMeetingAppBar> {
  Duration? elapsedTime;
  Timer? sessionTimer;
  List<AudioDeviceInfo>? mics;
  List<AudioDeviceInfo>? speakers;
  List<VideoDeviceInfo>? cameras;

  @override
  void initState() {
    startTimer();
    fetchVideoDevices();
    fetchAudioDevices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 8.0, 0.0),
      child: Row(
        children: [
          if (widget.recordingState == "RECORDING_STARTING" ||
              widget.recordingState == "RECORDING_STOPPING" ||
              widget.recordingState == "RECORDING_STARTED")
            RecordingIndicator(recordingState: widget.recordingState),
          if (widget.recordingState == "RECORDING_STARTING" ||
              widget.recordingState == "RECORDING_STOPPING" ||
              widget.recordingState == "RECORDING_STARTED")
            const HorizontalSpacer(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.meeting.id,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                        child: Icon(
                          Icons.copy,
                          size: 16,
                        ),
                      ),
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: widget.meeting.id));
                        showSnackBarMessage(
                            message: "Meeting ID has been copied.",
                            context: context);
                      },
                    ),
                  ],
                ),
                // VerticalSpacer(),
                Text(
                  elapsedTime == null
                      ? "00:00:00"
                      : elapsedTime.toString().split(".").first,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: black400),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TouchRippleEffect(
              borderRadius: BorderRadius.circular(12),
              rippleColor: primaryColor,
              onTap: () {
                if (widget.recordingState == "RECORDING_STOPPING") {
                  showSnackBarMessage(
                      message: "Recording is in stopping state",
                      context: context);
                } else if (widget.recordingState == "RECORDING_STARTED") {
                  widget.meeting.stopRecording();
                } else if (widget.recordingState == "RECORDING_STARTING") {
                  showSnackBarMessage(
                      message: "Recording is in starting state",
                      context: context);
                } else {
                  widget.meeting.startRecording();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
                  color: primaryColor,
                ),
                padding: const EdgeInsets.all(11),
                child: SvgPicture.asset(
                  "assets/ic_recording.svg",
                  width: 23,
                  height: 23,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Mic Control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TouchRippleEffect(
              borderRadius: BorderRadius.circular(12),
              rippleColor: primaryColor,
              onTap: () {
                if (widget.isMicEnabled) {
                  widget.meeting.muteMic();
                } else {
                  widget.meeting.unmuteMic();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
                  color: primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Row(
                  children: [
                    Icon(
                      widget.isMicEnabled ? Icons.mic : Icons.mic_off,
                      size: 25,
                      color: Colors.white,
                    ),
                    PopupMenuButton(
                      onOpened: () async {
                        fetchAudioDevices();
                      },
                      position: PopupMenuPosition.over,
                      padding: const EdgeInsets.all(0),
                      color: black700,
                      constraints: const BoxConstraints.tightFor(width: 330),
                      offset: const Offset(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      onSelected: (value) {
                        if (value == 'label') {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please select device')));
                        } else {
                          AudioDeviceInfo deviceInfo = value as AudioDeviceInfo;

                          if (deviceInfo.kind == "audiooutput") {
                            widget.meeting.switchAudioDevice(deviceInfo);
                          } else if (deviceInfo.kind == "audioinput") {
                            widget.meeting.changeMic(deviceInfo);
                          }
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          _buildMeetingPoupItem('label', 'Microphones', null,
                              leadingIcon: const Icon(Icons.mic,
                                  color: Color.fromARGB(255, 128, 125, 125),
                                  size: 20),
                              textColor: const Color.fromARGB(255, 128, 125, 125)),
                          PopupMenuItem(
                            padding: EdgeInsets.zero,
                            child: mics != null && mics!.isNotEmpty
                                ? Column(
                                    children: mics!
                                        .map(
                                          (e) => _buildMeetingPoupItem(
                                            e,
                                            e.label,
                                            null,
                                            isSelected: e.deviceId ==
                                                    widget.meeting.selectedMic
                                                        ?.deviceId
                                                ? true
                                                : false,
                                            leadingIcon: e.deviceId ==
                                                    widget.meeting.selectedMic
                                                        ?.deviceId
                                                ? const Icon(
                                                    Icons.check_circle,
                                                    color: Color.fromRGBO(
                                                        58, 165, 93, 1),
                                                    size: 20,
                                                  )
                                                : SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                          ),
                                        )
                                        .toList())
                                : const Text("No Microphone Devices found."),
                          ),
                          _buildMeetingPoupItem('label', 'Speakers', null,
                              leadingIcon: const Icon(
                                Icons.volume_up,
                                color: Color.fromARGB(255, 128, 125, 125),
                                size: 20
                              ),
                              textColor: const Color.fromARGB(255, 128, 125, 125)),
                          PopupMenuItem(
                            padding: EdgeInsets.zero,
                            child: speakers != null && speakers!.isNotEmpty
                                ? Column(
                                    children: speakers!
                                        .map(
                                          (e) => _buildMeetingPoupItem(
                                              e, e.label, null,
                                              isSelected: e.deviceId ==
                                                      widget
                                                          .meeting
                                                          .selectedSpeaker
                                                          ?.deviceId
                                                  ? true
                                                  : false,
                                              leadingIcon: e.deviceId ==
                                                      widget
                                                          .meeting
                                                          .selectedSpeaker
                                                          ?.deviceId
                                                  ? const Icon(
                                                      Icons.check_circle,
                                                      color: Color.fromRGBO(
                                                          58, 165, 93, 1),
                                                      size: 20,
                                                    )
                                                  : SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                    )),
                                        )
                                        .toList())
                                : const Text("No Speaker Devices found."),
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TouchRippleEffect(
              borderRadius: BorderRadius.circular(12),
              rippleColor: primaryColor,
              onTap: () {
                if (widget.isCamEnabled) {
                  widget.meeting.disableCam();
                } else {
                  widget.meeting.enableCam();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
                  color: primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Row(
                  children: [
                    Icon(
                      widget.isCamEnabled ? Icons.videocam : Icons.videocam_off,
                      size: 25,
                      color: Colors.white,
                    ),
                    PopupMenuButton(
                      onOpened: () async {
                        fetchVideoDevices();
                      },
                      position: PopupMenuPosition.over,
                      padding: const EdgeInsets.all(0),
                      color: black700,
                      constraints: const BoxConstraints.tightFor(width: 330),
                      offset: const Offset(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      onSelected: (value) {
                        VideoDeviceInfo camera = value as VideoDeviceInfo;
                        if (camera.deviceId !=
                            widget.meeting.selectedCam?.deviceId) {
                          widget.meeting.changeCam(camera);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            padding: EdgeInsets.zero,
                            child: cameras != null && cameras!.isNotEmpty
                                ? Column(
                                    children: cameras!
                                        .map(
                                          (e) => _buildMeetingPoupItem(
                                              e, e.label, null,
                                              isSelected: e.deviceId ==
                                                      widget.meeting.selectedCam
                                                          ?.deviceId
                                                  ? true
                                                  : false, leadingIcon: e.deviceId ==
                                                    widget.meeting.selectedCam
                                                        ?.deviceId
                                                ? const Icon(
                                              Icons.check_circle,
                                              color: Color.fromRGBO(
                                                  58, 165, 93,1),
                                                  size: 20,
                                            ) : SizedBox(width: 20, height: 20,)),
                                        )
                                        .toList())
                                : const Text("No Camera Devices found."),
                          ),
                        ];
                      },
                    )
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TouchRippleEffect(
              borderRadius: BorderRadius.circular(12),
              rippleColor: primaryColor,
              onTap: () {
                if (!widget.isRemoteScreenShareEnabled) {
                  if (!widget.isLocalScreenShareEnabled) {
                    if (!kIsWeb) {
                      selectScreenSourceDialog(context).then((value) => {
                            if (value != null)
                              {widget.meeting.enableScreenShare(value)}
                          });
                    } else {
                      widget.meeting.enableScreenShare();
                    }
                  } else {
                    widget.meeting.disableScreenShare();
                  }
                } else {
                  showSnackBarMessage(
                      message: "Someone is already presenting",
                      context: context);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
                  color: primaryColor,
                ),
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  widget.isLocalScreenShareEnabled
                      ? "assets/ic_stop_screen_share.svg"
                      : "assets/ic_screen_share.svg",
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TouchRippleEffect(
              borderRadius: BorderRadius.circular(12),
              rippleColor: primaryColor,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(0.0),
                      content: SizedBox(
                        width: kIsWeb
                            ? MediaQuery.of(context).size.width / 2.3
                            : MediaQuery.of(context).size.width / 1.7,
                        height: kIsWeb
                            ? MediaQuery.of(context).size.height / 1.5
                            : MediaQuery.of(context).size.height / 1.7,
                        child: ChatView(meeting: widget.meeting),
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
                  color: primaryColor,
                ),
                padding: const EdgeInsets.all(11),
                child: SvgPicture.asset(
                  "assets/ic_chat.svg",
                  width: 23,
                  height: 23,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TouchRippleEffect(
              borderRadius: BorderRadius.circular(12),
              rippleColor: primaryColor,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(0.0),
                      content: SizedBox(
                        width: kIsWeb
                            ? MediaQuery.of(context).size.width / 2.3
                            : MediaQuery.of(context).size.width / 1.7,
                        height: kIsWeb
                            ? MediaQuery.of(context).size.height / 1.5
                            : MediaQuery.of(context).size.height / 1.7,
                        child: ParticipantList(meeting: widget.meeting),
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
                  color: primaryColor,
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.people,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: PopupMenuButton(
                position: PopupMenuPosition.under,
                padding: const EdgeInsets.all(0),
                color: black700,
                icon: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                offset: const Offset(0, 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) => {
                      if (value == "leave")
                        widget.meeting.leave()
                      else if (value == "end")
                        widget.meeting.end()
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
        ],
      ),
    );
  }

  Future<void> startTimer() async {
    dynamic session = await fetchSession(widget.token, widget.meeting.id);
    DateTime sessionStartTime = DateTime.parse(session['start']);
    final difference = DateTime.now().difference(sessionStartTime);

    setState(() {
      elapsedTime = difference;
      sessionTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
            elapsedTime = Duration(
                seconds: elapsedTime != null ? elapsedTime!.inSeconds + 1 : 0);
          });
        },
      );
    });
    // log("session start time" + session.data[0].start.toString());
  }

  void fetchVideoDevices() async {
    cameras = await VideoSDK.getVideoDevices();
    setState(() {});
  }

  void fetchAudioDevices() async {
    List<AudioDeviceInfo>? audioDevices = await VideoSDK.getAudioDevices();
    mics = [];
    speakers = [];
    if (audioDevices != null) {
      for (AudioDeviceInfo device in audioDevices) {
        if (device.kind == 'audiooutput') {
          speakers?.add(device);
        } else {
          mics?.add(device);
        }
      }
      setState(() {});
    }
  }

  Future<DesktopCapturerSource?> selectScreenSourceDialog(
      BuildContext context) async {
    final source = await showDialog<DesktopCapturerSource>(
      context: context,
      builder: (context) => ScreenSelectDialog(
        meeting: widget.meeting,
      ),
    );
    return source;
  }

  PopupMenuItem<dynamic> _buildMeetingPoupItem(
      dynamic value, String title, String? description,
      {Widget? leadingIcon, Color? textColor, bool isSelected = false}) {
    return PopupMenuItem(
      value: value,
      padding: EdgeInsets.zero,
      child: Container(
        color: isSelected
            ? Color.fromRGBO(109, 110, 113, 1)
            : Colors.transparent, // Set the selected color
        padding: const EdgeInsets.symmetric(
            vertical: 8), // Only vertical padding to avoid side spaces
        margin: EdgeInsets.zero, // Remove margin to avoid spaces on sides
        child: Row(
          children: [
            if (leadingIcon != null)
              const SizedBox(width: 16), // Manual spacing on the left
            leadingIcon ?? const Center(),
            const HorizontalSpacer(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? Colors.white,
                    ),
                  ),
                  if (description != null) const VerticalSpacer(4),
                  if (description != null)
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: black400,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16), // Manual spacing on the right
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (sessionTimer != null) {
      sessionTimer!.cancel();
    }
    super.dispose();
  }
}
