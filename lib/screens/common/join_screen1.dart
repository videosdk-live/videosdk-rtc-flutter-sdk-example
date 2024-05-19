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
import 'dropdowns.dart';
import 'dropdowns_Web.dart';

// Join Screen
class JoinScreen extends StatefulWidget {
  const JoinScreen({Key? key}) : super(key: key);

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> with WidgetsBindingObserver {
  String _token = "";

  // Control Status
  bool isMicOn = false;
  bool isCameraOn = false;

  CustomTrack? cameraTrack;
  RTCVideoRenderer? cameraRenderer;

  bool? isJoinMeetingSelected;
  bool? isCreateMeetingSelected;

  bool? isCameraPermissionAllowed = false;
  bool? isMicrophonePermissionAllowed = false;

  VideoDeviceInfo? selectedVideoDevice;
  AudioDeviceInfo? selectedAudioOutputDevice;
  AudioDeviceInfo? selectedAudioInputDevice;
  List<VideoDeviceInfo>? videoDevices;
  List<AudioDeviceInfo>? audioDevices;
  List<AudioDeviceInfo> audioInputDevices = [];
  List<AudioDeviceInfo> audioOutputDevices = [];

  @override
  void initState() {
    super.initState();
    // registerVideoSDKEvent();
    // print("Event listener registered");

    WidgetsBinding.instance.addObserver(this);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await fetchToken(context);
      setState(() => _token = token);
    });
    checkandReqPermissions();
    VideoSDK.on(Events.deviceChanged, (devices) {
      print("In Device CHanged ");
      getDevices();
    });
  }

  void updateselectedAudioOutputDevice(AudioDeviceInfo? device) {
    setState(() {
      selectedAudioOutputDevice = device;
    });
  }

  void updateselectedAudioInputDevice(AudioDeviceInfo? device) {
    setState(() {
      selectedAudioInputDevice = device;
    });
  }

  void updateSelectedVideoDevice(VideoDeviceInfo? device) {
    setState(() {
      selectedVideoDevice = device;
    });
    initCameraPreview();
  }

  void checkBluetoothPermissions() async {
    bool? bluetoothPerm = await VideoSDK.checkBluetoothPermission();
    if (bluetoothPerm != null && bluetoothPerm != true) {
      await VideoSDK.requestBluetoothPermission();
    }
  }

  void getDevices() async {
    if (isCameraPermissionAllowed != null &&
        isCameraPermissionAllowed == true) {
      videoDevices = await VideoSDK.getVideoDevices();
      setState(() {
        selectedVideoDevice = videoDevices?.first;
        initCameraPreview();
      });
    }
    if (isMicrophonePermissionAllowed != null &&
        isMicrophonePermissionAllowed == true) {
      audioDevices = await VideoSDK.getAudioDevices();
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        setState(() {
          selectedAudioOutputDevice = audioDevices?.first;
        });
      } else {
        for (AudioDeviceInfo device in audioDevices!) {
          if (device.kind == 'audioinput') {
            audioInputDevices.add(device);
          } else {
            audioOutputDevices.add(device);
          }
        }

        setState(() {
          selectedAudioOutputDevice = audioOutputDevices.first;
          selectedAudioInputDevice = audioInputDevices.first;
        });
      }
    }
  }

  void checkandReqPermissions([Permissions? perm]) async {
    perm ??= Permissions.audio_video;
    try {
      Map<String, bool>? permissions = await VideoSDK.checkPermissions();

      if (perm == Permissions.audio || perm == Permissions.audio_video) {
        if (permissions?['audio'] != true) {
          Map<String, bool>? reqPermissions =
              await VideoSDK.requestPermissions(Permissions.audio);
          setState(() {
            isMicrophonePermissionAllowed = reqPermissions?['audio'];
            isMicOn = reqPermissions!['audio']!;
          });
        } else {
          setState(() {
            isMicrophonePermissionAllowed = true;
            isMicOn = true;
          });
        }
      }

      if (perm == Permissions.video || perm == Permissions.audio_video) {
        if (permissions?['video'] != true) {
          Map<String, bool>? reqPermissions =
              await VideoSDK.requestPermissions(Permissions.video);
          setState(() => isCameraPermissionAllowed = reqPermissions?['video']);
        } else {
          setState(() => isCameraPermissionAllowed = true);
        }
      }
      if (!kIsWeb && Platform.isAndroid) {
        checkBluetoothPermissions();
      }

      getDevices();
    } catch (e) {
      print("error $e");
    }
  }

  void checkPermissions() async {
    Map<String, bool>? permissions = await VideoSDK.checkPermissions();
    setState(() {
      isMicrophonePermissionAllowed = permissions?['audio'];
      isCameraPermissionAllowed = permissions?['video'];
      isMicOn = permissions!['audio']!;
      isCameraOn = permissions['video']!;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        checkPermissions();
        break;
    }
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
          appBar: !kIsWeb && (Platform.isAndroid || Platform.isIOS)
              ? AppBar(
                  flexibleSpace: Align(
                    child: Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 40, 10, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.settings,
                                size: 30,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 250,
                                      color: black750,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            DropdownsWidget(
                                              isCameraPermissionAllowed:
                                                  isCameraPermissionAllowed,
                                              isMicrophonePermissionAllowed:
                                                  isMicrophonePermissionAllowed,
                                              selectedAudioOutputDevice:
                                                  selectedAudioOutputDevice,
                                              selectedVideoDevice:
                                                  selectedVideoDevice,
                                              audioDevices: audioDevices,
                                              videoDevices: videoDevices,
                                              onAudioDeviceSelected:
                                                  updateselectedAudioOutputDevice,
                                              onVideoDeviceSelected:
                                                  updateSelectedVideoDevice,
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  backgroundColor: black750,
                  elevation: 0,
                )
              : null,
          backgroundColor: primaryColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                        ),
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
                            padding: const EdgeInsets.fromLTRB(36, 100, 36, 40),
                            child: SizedBox(
                              height: 400,
                              width: 200,
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  AspectRatio(
                                    aspectRatio: ResponsiveValue<double>(
                                        context,
                                        conditionalValues: [
                                          Condition.equals(
                                              name: MOBILE, value: 1 / 1.55),
                                          Condition.equals(
                                              name: TABLET, value: 16 / 10),
                                          Condition.largerThan(
                                              name: TABLET, value: 16 / 8),
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
                                                    BorderRadius.circular(12)),
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
                                            onPressed: () =>
                                                isMicrophonePermissionAllowed !=
                                                            null &&
                                                        isMicrophonePermissionAllowed ==
                                                            true
                                                    ? setState(
                                                        () =>
                                                            isMicOn = !isMicOn,
                                                      )
                                                    : checkandReqPermissions(
                                                        Permissions.audio),
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
                                            onPressed: () =>
                                                isCameraPermissionAllowed !=
                                                            null &&
                                                        isCameraPermissionAllowed ==
                                                            true
                                                    ? {
                                                        if (isCameraOn)
                                                          {
                                                            disposeCameraPreview()
                                                          }
                                                        else
                                                          {initCameraPreview()},
                                                        setState(() =>
                                                            isCameraOn =
                                                                !isCameraOn)
                                                      }
                                                    : checkandReqPermissions(
                                                        Permissions.video),
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
                          kIsWeb || Platform.isMacOS || Platform.isWindows
                              ? Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      250, 0, 250, 50),
                                  child: DropdownsWebWidget(
                                    isCameraPermissionAllowed:
                                        isCameraPermissionAllowed,
                                    isMicrophonePermissionAllowed:
                                        isMicrophonePermissionAllowed,
                                    selectedAudioOutputDevice:
                                        selectedAudioOutputDevice,
                                    selectedAudioInputDevice:
                                        selectedAudioInputDevice,
                                    selectedVideoDevice: selectedVideoDevice,
                                    audioInputDevices: audioInputDevices,
                                    audioOutputDevices: audioOutputDevices,
                                    videoDevices: videoDevices,
                                    onAudioOutputDeviceSelected:
                                        updateselectedAudioOutputDevice,
                                    onAudioInputDeviceSelected:
                                        updateselectedAudioInputDevice,
                                    onVideoDeviceSelected:
                                        updateSelectedVideoDevice,
                                  ),
                                )
                              : Container(),
                      
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
    if (isCameraPermissionAllowed != null &&
        isCameraPermissionAllowed == true) {
      CustomTrack track = await VideoSDK.createCameraVideoTrack(
          cameraId: selectedVideoDevice?.deviceId);
      RTCVideoRenderer render = RTCVideoRenderer();
      await render.initialize();
      render.setSrcObject(
          stream: track.mediaStream,
          trackId: track.mediaStream.getVideoTracks().first.id);
      setState(() {
        cameraTrack = track;
        cameraRenderer = render;
        isCameraOn = true;
      });
    }
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
        //disposeCameraPreview();
        setState(() {
          cameraRenderer = null;
        });
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
                  selectedAudioOutputDevice: selectedAudioOutputDevice,
                  selectedAudioInputDevice: selectedAudioInputDevice,
                  cameraTrack: cameraTrack),
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
                selectedAudioInputDevice: selectedAudioInputDevice,
                selectedAudioOutputDevice: selectedAudioOutputDevice,
                cameraTrack: cameraTrack,
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
        setState(() {
          cameraRenderer = null;
        });
        //disposeCameraPreview();
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
                  selectedAudioOutputDevice: selectedAudioOutputDevice,
                  selectedAudioInputDevice: selectedAudioInputDevice,
                  cameraTrack: cameraTrack),
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
                selectedAudioInputDevice: selectedAudioInputDevice,
                selectedAudioOutputDevice: selectedAudioOutputDevice,
                cameraTrack: cameraTrack,
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
