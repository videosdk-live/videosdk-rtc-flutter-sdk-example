// ignore_for_file: non_constant_identifier_names, dead_code
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/screens/conference-call/conference_meeting_screen.dart';
import 'package:videosdk_flutter_example/utils/api.dart';
import 'package:videosdk_flutter_example/widgets/common/joining_details/joining_details.dart';

import '../../constants/colors.dart';
import '../../utils/spacer.dart';
import '../../utils/toast.dart';
import '../one-to-one/one_to_one_meeting_screen.dart';

// Join Screen
class JoinScreen extends StatefulWidget {
  const JoinScreen({Key? key}) : super(key: key);

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  String _token = "";

  // Control Status
  bool isMicOn = true;
  bool isCameraOn = true;

  CustomTrack? cameraTrack;
  RTCVideoRenderer? cameraRenderer;

  bool? isJoinMeetingSelected;
  bool? isCreateMeetingSelected;

  @override
  void initState() {
    initCameraPreview();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await fetchToken(context);
      setState(() => _token = token);
    });
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: _onWillPopScope,
        child: Scaffold(
          backgroundColor: primaryColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment:
                            !kIsWeb && (Platform.isAndroid || Platform.isIOS)
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Camera Preview
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 100, horizontal: 36),
                            child:
                                SizedBox(
                                  height: 300,
                                  width: 200,
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      
                                         AspectRatio(
                                              aspectRatio: ResponsiveValue<double>(
                                                  context,
                                                  conditionalValues: [
                                                    Condition.equals(
                                                        name: MOBILE,
                                                        value: 1 / 1.55),
                                                    Condition.equals(
                                                        name: TABLET,
                                                        value: 16 / 10),
                                                    Condition.largerThan(
                                                        name: TABLET,
                                                        value: 16 / 9),
                                                  ]).value!,
                                              child: cameraRenderer != null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                      child: RTCVideoView(
                                                        cameraRenderer
                                                            as RTCVideoRenderer,
                                                        objectFit: RTCVideoViewObjectFit
                                                            .RTCVideoViewObjectFitCover,
                                                      ),
                                                    )
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                          color: black800,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  12)),
                                                      child: const Center(
                                                        child: Text(
                                                          "Camera is turned off",
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                  Positioned(
                                    bottom: 16,
                                    // Meeting ActionBar
                                    child: Center(
                                      child: Row(
                                        children: [
                                          // Mic Action Button
                                          ElevatedButton(
                                            onPressed: () => setState(
                                              () => isMicOn = !isMicOn,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              shape: const CircleBorder(),
                                              padding: EdgeInsets.all(
                                                ResponsiveValue<double>(context,
                                                    conditionalValues: [
                                                      Condition.equals(
                                                          name: MOBILE,
                                                          value: 12),
                                                      Condition.equals(
                                                          name: TABLET,
                                                          value: 15),
                                                      Condition.equals(
                                                          name: DESKTOP,
                                                          value: 18),
                                                    ]).value!,
                                              ),
                                              backgroundColor:
                                                  isMicOn ? Colors.white : red,
                                              foregroundColor: Colors.black,
                                            ),
                                            child: Icon(
                                                isMicOn
                                                    ? Icons.mic
                                                    : Icons.mic_off,
                                                color: isMicOn
                                                    ? grey
                                                    : Colors.white),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (isCameraOn) {
                                                disposeCameraPreview();
                                              } else {
                                                initCameraPreview();
                                              }
                                              setState(() =>
                                                  isCameraOn = !isCameraOn);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: const CircleBorder(),
                                              padding: EdgeInsets.all(
                                                ResponsiveValue<double>(context,
                                                    conditionalValues: [
                                                      Condition.equals(
                                                          name: MOBILE,
                                                          value: 12),
                                                      Condition.equals(
                                                          name: TABLET,
                                                          value: 15),
                                                      Condition.equals(
                                                          name: DESKTOP,
                                                          value: 18),
                                                    ]).value!,
                                              ),
                                              backgroundColor: isCameraOn
                                                  ? Colors.white
                                                  : red,
                                            ),
                                            child: Icon(
                                              isCameraOn
                                                  ? Icons.videocam
                                                  : Icons.videocam_off,
                                              color: isCameraOn
                                                  ? grey
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Column(
                              children: [
                                if (isJoinMeetingSelected == null &&
                                    isCreateMeetingSelected == null)
                                  MaterialButton(
                                      minWidth: ResponsiveValue<double>(context,
                                          conditionalValues: [
                                            Condition.equals(
                                                name: MOBILE,
                                                value: maxWidth / 1.3),
                                            Condition.equals(
                                                name: TABLET,
                                                value: maxWidth / 1.3),
                                            Condition.equals(
                                                name: DESKTOP, value: 600),
                                          ]).value!,
                                      height: 50,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      color: purple,
                                      child: const Text("Create Meeting",
                                          style: TextStyle(fontSize: 16)),
                                      onPressed: () => {
                                            setState(() => {
                                                  isCreateMeetingSelected =
                                                      true,
                                                  isJoinMeetingSelected = true
                                                })
                                          }),
                                const VerticalSpacer(16),
                                if (isJoinMeetingSelected == null &&
                                    isCreateMeetingSelected == null)
                                  MaterialButton(
                                      minWidth: ResponsiveValue<double>(context,
                                          conditionalValues: [
                                            Condition.equals(
                                                name: MOBILE,
                                                value: maxWidth / 1.3),
                                            Condition.equals(
                                                name: TABLET,
                                                value: maxWidth / 1.3),
                                            Condition.equals(
                                                name: DESKTOP, value: 600),
                                          ]).value!,
                                      height: 50,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      color: black750,
                                      child: const Text("Join Meeting",
                                          style: TextStyle(fontSize: 16)),
                                      onPressed: () => {
                                            setState(() => {
                                                  isCreateMeetingSelected =
                                                      false,
                                                  isJoinMeetingSelected = true
                                                })
                                          }),
                                if (isJoinMeetingSelected != null &&
                                    isCreateMeetingSelected != null)
                                  JoiningDetails(
                                    isCreateMeeting: isCreateMeetingSelected!,
                                    onClickMeetingJoin: (meetingId, callType,
                                            displayName) =>
                                        _onClickMeetingJoin(
                                            meetingId, callType, displayName),
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }

  Future<bool> _onWillPopScope() async {
    if (isJoinMeetingSelected != null && isCreateMeetingSelected != null) {
      setState(() {
        isJoinMeetingSelected = null;
        isCreateMeetingSelected = null;
      });
      return false;
    } else {
      return true;
    }
  }

  void initCameraPreview() async {
    CustomTrack track = await VideoSDK.createCameraVideoTrack();
    RTCVideoRenderer render = RTCVideoRenderer();
    await render.initialize();
    render.setSrcObject(stream: track.mediaStream, trackId: track.mediaStream.getVideoTracks().first.id);
    setState(() {
      cameraTrack = track;
      cameraRenderer = render;
    });
  }

  void disposeCameraPreview() {
    cameraTrack?.dispose();
    setState(() {
      cameraRenderer = null;
      cameraTrack = null;
    });
  }

  void _onClickMeetingJoin(meetingId, callType, displayName) async {
    if (displayName.toString().isEmpty) {
      displayName = "Guest";
    }
    if (isCreateMeetingSelected!) {
      createAndJoinMeeting(callType, displayName);
    } else {
      joinMeeting(callType, displayName, meetingId);
    }
  }

  Future<void> createAndJoinMeeting(callType, displayName) async {
    try {
      var _meetingID = await createMeeting(_token);
      if (mounted) {
        disposeCameraPreview();
        if (callType == "GROUP") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfereneceMeetingScreen(
                token: _token,
                meetingId: _meetingID,
                displayName: displayName,
                micEnabled: isMicOn,
                camEnabled: isCameraOn,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OneToOneMeetingScreen(
                token: _token,
                meetingId: _meetingID,
                displayName: displayName,
                micEnabled: isMicOn,
                camEnabled: isCameraOn,
              ),
            ),
          );
        }
      }
    } catch (error) {
      showSnackBarMessage(message: error.toString(), context: context);
    }
  }

  Future<void> joinMeeting(callType, displayName, meetingId) async {
    if (meetingId.isEmpty) {
      showSnackBarMessage(
          message: "Please enter Valid Meeting ID", context: context);
      return;
    }
    var validMeeting = await validateMeeting(_token, meetingId);
    if (validMeeting) {
      if (mounted) {
        disposeCameraPreview();
        if (callType == "GROUP") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfereneceMeetingScreen(
                token: _token,
                meetingId: meetingId,
                displayName: displayName,
                micEnabled: isMicOn,
                camEnabled: isCameraOn,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OneToOneMeetingScreen(
                token: _token,
                meetingId: meetingId,
                displayName: displayName,
                micEnabled: isMicOn,
                camEnabled: isCameraOn,
              ),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        showSnackBarMessage(message: "Invalid Meeting ID", context: context);
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    cameraTrack?.dispose();
    super.dispose();
  }
}
