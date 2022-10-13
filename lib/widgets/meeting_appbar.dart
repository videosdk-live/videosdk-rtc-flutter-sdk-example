import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/utils/spacer.dart';
import 'package:videosdk_flutter_example/utils/toast.dart';

class MeetingAppBar extends StatefulWidget {
  String token;
  Room meeting;
  bool isRecordingOn;
  bool isFullScreen;
  MeetingAppBar(
      {Key? key,
      required this.meeting,
      required this.token,
      required this.isFullScreen,
      required this.isRecordingOn})
      : super(key: key);

  @override
  State<MeetingAppBar> createState() => MeetingAppBarState();
}

class MeetingAppBarState extends State<MeetingAppBar> {
  Duration? elapsedTime;
  Timer? sessionTimer;

  List<MediaDeviceInfo> cameras = [];

  @override
  void initState() {
    startTimer();
    // Holds available cameras info
    cameras = widget.meeting.getCameras();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: !widget.isFullScreen
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      secondChild: const SizedBox.shrink(),
      firstChild: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            if (widget.isRecordingOn)
              Lottie.asset('assets/recording_lottie.json', height: 35),
            if (widget.isRecordingOn) const HorizontalSpacer(),
            Column(
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
          ],
        ),
        actions: [
          // Recording status
          IconButton(
            icon: SvgPicture.asset("assets/ic_switch_camera.svg"),
            onPressed: () {
              MediaDeviceInfo newCam = cameras.firstWhere(
                  (camera) => camera.deviceId != widget.meeting.selectedCamId);
              widget.meeting.changeCam(newCam.deviceId);
            },
          ),
        ],
      ),
    );
  }

  Future<void> startTimer() async {
    final String? _VIDEOSDK_API_ENDPOINT = dotenv.env['VIDEOSDK_API_ENDPOINT'];

    final Uri getMeetingIdUrl = Uri.parse(
        '$_VIDEOSDK_API_ENDPOINT/sessions?roomId=${widget.meeting.id}');
    final http.Response meetingIdResponse =
        await http.get(getMeetingIdUrl, headers: {
      "Authorization": widget.token,
    });
    List<dynamic> sessions = jsonDecode(meetingIdResponse.body)['data'];
    DateTime sessionStartTime = DateTime.parse((sessions.first)['start']);
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

  @override
  void dispose() {
    if (sessionTimer != null) {
      sessionTimer!.cancel();
    }
    super.dispose();
  }
}
