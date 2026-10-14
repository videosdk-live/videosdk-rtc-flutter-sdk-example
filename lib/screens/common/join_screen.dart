// ignore_for_file: non_constant_identifier_names, dead_code
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/screens/conference-call/conference_meeting_screen.dart';
import 'package:videosdk_flutter_example/utils/api.dart';
import 'package:videosdk_flutter_example/widgets/common/joining/join_options.dart';
import '../../constants/colors.dart';
import '../../utils/toast.dart';
import '../../widgets/common/joining/join_view.dart';
import '../one-to-one/one_to_one_meeting_screen.dart';
import '../../widgets/common/pre_call/dropdowns_Web.dart';
import '../../widgets/common/pre_call/selectAudioDevice.dart';
import '../../widgets/common/pre_call/selectVideoDevice.dart';

// Join Screen
class JoinScreen extends StatefulWidget {
  const JoinScreen({Key? key}) : super(key: key);

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> with WidgetsBindingObserver {
  String _token = "";

  // Control Status
  bool isMicOn =
      !kIsWeb && (Platform.isMacOS || Platform.isWindows) ? true : false;
  bool isCameraOn =
      !kIsWeb && (Platform.isMacOS || Platform.isWindows) ? true : false;

  CustomStreamTrack? cameraTrack;
  CustomStreamTrack? microphoneTrack;
  RTCVideoRenderer? cameraRenderer;

  bool? isJoinMeetingSelected;
  bool? isCreateMeetingSelected;

  bool? isCameraPermissionAllowed =
      !kIsWeb && (Platform.isMacOS || Platform.isWindows) ? true : false;
  bool? isMicrophonePermissionAllowed =
      !kIsWeb && (Platform.isMacOS || Platform.isWindows) ? true : false;

  CameraDeviceInfo? selectedVideoDevice;
  MicrophoneDeviceInfo? selectedAudioOutputDevice;
  MicrophoneDeviceInfo? selectedAudioInputDevice;
  List<CameraDeviceInfo>? videoDevices;
  List<MicrophoneDeviceInfo>? audioDevices;
  List<MicrophoneDeviceInfo> audioInputDevices = [];
  List<MicrophoneDeviceInfo> audioOutputDevices = [];

  @override
  void initState() {
    super.initState();

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
  }

  void updateselectedAudioOutputDevice(MicrophoneDeviceInfo? device) {
    if (device?.deviceId != selectedAudioOutputDevice?.deviceId) {
      setState(() {
        selectedAudioOutputDevice = device;
      });
      if (!kIsWeb) {
        if (Platform.isAndroid || Platform.isIOS) {
          disposeMicTrack();
          initMic();
        }
      }
    }
  }

  void updateselectedAudioInputDevice(MicrophoneDeviceInfo? device) {
    if (device?.deviceId != selectedAudioInputDevice?.deviceId) {
      setState(() {
        selectedAudioInputDevice = device;
      });
      disposeMicTrack();
      initMic();
    }
  }

  void updateSelectedVideoDevice(CameraDeviceInfo? device) {
    if (device?.deviceId != selectedVideoDevice?.deviceId) {

      disposeCameraPreview();
      setState(() {
        selectedVideoDevice = device;
      });
      
      initCameraPreview();
    }
  }

  Future<void> checkBluetoothPermissions() async {
    try {
      bool bluetoothPerm = await VideoSDK.checkBluetoothPermission();
      if (bluetoothPerm != true) {
        await VideoSDK.requestBluetoothPermission();
      }
    } catch (e) {}
  }

  void getDevices() async {
    if (isCameraPermissionAllowed != null &&
        isCameraPermissionAllowed == true) {
      videoDevices = await VideoSDK.getCameras();
      setState(() {
        selectedVideoDevice = videoDevices?.first;
      });
      initCameraPreview();
    }
    if (isMicrophonePermissionAllowed != null &&
        isMicrophonePermissionAllowed == true) {
      audioDevices = await VideoSDK.getMics();
      if (!kIsWeb && !Platform.isMacOS && !Platform.isWindows) {
        //Condition for android and ios devices
        setState(() {
          selectedAudioOutputDevice = audioDevices?.first;
        });
      } else {
        audioInputDevices = [];
        audioOutputDevices = [];
        for (MicrophoneDeviceInfo device in audioDevices!) {
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
        initMic();
      }
    }
  }

  void checkandReqPermissions([Permissions? perm]) async {
    perm ??= Permissions.AUDIO_VIDEO;
    try {
      if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
        Map<String, bool> permissions = await VideoSDK.checkPermissions();

        if (perm == Permissions.AUDIO || perm == Permissions.AUDIO_VIDEO) {
          if (permissions['audio'] != true) {
            Map<String, bool> reqPermissions =
                await VideoSDK.requestPermissions(Permissions.AUDIO);
            setState(() {
              isMicrophonePermissionAllowed = reqPermissions['audio'];
              isMicOn = reqPermissions['audio']!;
            });
          } else {
            setState(() {
              isMicrophonePermissionAllowed = true;
              isMicOn = true;
            });
          }
        }

        if (perm == Permissions.VIDEO || perm == Permissions.AUDIO_VIDEO) {
          if (permissions['video'] != true) {
            Map<String, bool> reqPermissions =
                await VideoSDK.requestPermissions(Permissions.VIDEO);

            setState(() => isCameraPermissionAllowed = reqPermissions['video']);
          } else {
            setState(() => isCameraPermissionAllowed = true);
          }
        }
        if (!kIsWeb) {
          if (Platform.isAndroid) {
            await checkBluetoothPermissions();
          }
        }
      }
      getDevices();
    } catch (e) {}
  }

  void checkPermissions() async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      Map<String, bool> permissions = await VideoSDK.checkPermissions();
      setState(() {
        isMicrophonePermissionAllowed = permissions['audio'];
        isCameraPermissionAllowed = permissions['video'];
        isMicOn = permissions['audio']!;
        isCameraOn = permissions['video']!;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkPermissions();
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
    final maxHeight = MediaQuery.of(context).size.height;
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
          _onWillPopScope();
        },
        child: Scaffold(
          appBar: !kIsWeb && (Platform.isAndroid || Platform.isIOS)
              ? AppBar(
                  flexibleSpace: Align(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 40, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.volume_up,
                              size: 27,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                      color: black750,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: SelectAudioDevice(
                                            isMicrophonePermissionAllowed:
                                                isMicrophonePermissionAllowed,
                                            selectedAudioOutputDevice:
                                                selectedAudioOutputDevice,
                                            audioDevices: audioDevices,
                                            onAudioDeviceSelected:
                                                updateselectedAudioOutputDevice,
                                          )));
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.camera_alt_rounded,
                              size: 27,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    color: black750,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: SelectVideoDevice(
                                        isCameraPermissionAllowed:
                                            isCameraPermissionAllowed,
                                        selectedVideoDevice:
                                            selectedVideoDevice,
                                        videoDevices: videoDevices,
                                        onVideoDeviceSelected:
                                            updateSelectedVideoDevice,
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
                  backgroundColor: black750,
                  elevation: 0,
                )
              : null,
          backgroundColor: primaryColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                Widget _buildContent() {
                  return IntrinsicHeight(
                    child: kIsWeb || Platform.isWindows || Platform.isMacOS
                        ? Container(
                            margin: const EdgeInsets.fromLTRB(40, 150, 40, 150),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    height: maxHeight,
                                    width: maxWidth / 2,
                                    child: Column(
                                      children: [
                                        JoinView(
                                          cameraRenderer: cameraRenderer,
                                          isMicOn: isMicOn,
                                          isCameraOn: isCameraOn,
                                          onMicToggle: () =>
                                              isMicrophonePermissionAllowed !=
                                                          null &&
                                                      isMicrophonePermissionAllowed ==
                                                          true
                                                  ? {
                                                      if (isMicOn)
                                                        {disposeMicTrack()}
                                                      else
                                                        {initMic()},
                                                      setState(
                                                        () =>
                                                            isMicOn = !isMicOn,
                                                      )
                                                    }
                                                  : checkandReqPermissions(
                                                      Permissions.AUDIO),
                                          onCameraToggle: () {
                                            isCameraPermissionAllowed != null &&
                                                    isCameraPermissionAllowed ==
                                                        true
                                                ? {
                                                    if (isCameraOn)
                                                      {disposeCameraPreview()}
                                                    else
                                                      {initCameraPreview()},
                                                    setState(() => isCameraOn =
                                                        !isCameraOn)
                                                  }
                                                : checkandReqPermissions(
                                                    Permissions.VIDEO);
                                          },
                                        ),
                                        kIsWeb ||
                                                Platform.isMacOS ||
                                                Platform.isWindows
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 20, 0, 0),
                                                child: DropdownsWebWidget(
                                                  isCameraPermissionAllowed:
                                                      isCameraPermissionAllowed,
                                                  isMicrophonePermissionAllowed:
                                                      isMicrophonePermissionAllowed,
                                                  selectedAudioOutputDevice:
                                                      selectedAudioOutputDevice,
                                                  selectedAudioInputDevice:
                                                      selectedAudioInputDevice,
                                                  selectedVideoDevice:
                                                      selectedVideoDevice,
                                                  audioInputDevices:
                                                      audioInputDevices,
                                                  audioOutputDevices:
                                                      audioOutputDevices,
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
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: maxWidth / 10),
                                    child: JoinOptions(
                                      isJoinMeetingSelected:
                                          isJoinMeetingSelected,
                                      isCreateMeetingSelected:
                                          isCreateMeetingSelected,
                                      maxWidth: maxWidth,
                                      onOptionSelected: (isCreateMeeting) {
                                        setState(() {
                                          isCreateMeetingSelected =
                                              isCreateMeeting;
                                          isJoinMeetingSelected = true;
                                        });
                                      },
                                      onClickMeetingJoin: _onClickMeetingJoin,
                                    ),
                                  )
                                ]),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                                SizedBox(
                                  height: 400,
                                  width: maxWidth,
                                  child: JoinView(
                                    cameraRenderer: cameraRenderer,
                                    isMicOn: isMicOn,
                                    isCameraOn: isCameraOn,
                                    onMicToggle: () =>
                                        isMicrophonePermissionAllowed != null &&
                                                isMicrophonePermissionAllowed ==
                                                    true
                                            ? {
                                                if (isMicOn)
                                                  {disposeMicTrack()}
                                                else
                                                  {initMic()},
                                                setState(
                                                  () => isMicOn = !isMicOn,
                                                )
                                              }
                                            : checkandReqPermissions(
                                                Permissions.AUDIO),
                                    onCameraToggle: () {
                                      isCameraPermissionAllowed != null &&
                                              isCameraPermissionAllowed == true
                                          ? {
                                              if (isCameraOn)
                                                {disposeCameraPreview()}
                                              else
                                                {initCameraPreview()},
                                              setState(() =>
                                                  isCameraOn = !isCameraOn)
                                            }
                                          : checkandReqPermissions(
                                              Permissions.VIDEO);
                                    },
                                  ),
                                ),
                                JoinOptions(
                                  isJoinMeetingSelected: isJoinMeetingSelected,
                                  isCreateMeetingSelected:
                                      isCreateMeetingSelected,
                                  maxWidth: maxWidth,
                                  onOptionSelected: (isCreateMeeting) {
                                    setState(() {
                                      isCreateMeetingSelected = isCreateMeeting;
                                      isJoinMeetingSelected = true;
                                    });
                                  },
                                  onClickMeetingJoin: _onClickMeetingJoin,
                                )
                              ]),
                  );
                }

                return kIsWeb || Platform.isMacOS || Platform.isWindows
                    ? ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: viewportConstraints.maxHeight),
                        child: _buildContent(),
                      )
                    : SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minHeight: viewportConstraints.maxHeight),
                          child: _buildContent(),
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
        isCameraPermissionAllowed == true ) {
      try {
        CustomStreamTrack track = await VideoSDK.createCameraVideoTrack(
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
      } on VideoSDKError catch (e) {
        showSnackBarMessage(message: e.message, context: context);
      }
    }
  }

  void initMic() async {
    if (isMicrophonePermissionAllowed != null &&
        isMicrophonePermissionAllowed == true) {
      try {
        CustomStreamTrack track = await VideoSDK.createMicrophoneAudioTrack(
            microphoneId: kIsWeb || Platform.isMacOS || Platform.isWindows
                ? selectedAudioInputDevice?.deviceId
                : selectedAudioOutputDevice?.deviceId);
        setState(() {
          microphoneTrack = track;
        });
      } on VideoSDKError catch (e) {
        showSnackBarMessage(message: e.message, context: context);
      }
    }
  }

  void disposeCameraPreview() {
    cameraTrack?.stop();
    setState(() {
      cameraRenderer = null;
      cameraTrack = null;
    });
  }

  void disposeMicTrack() {
    microphoneTrack?.stop();
    setState(() {
      microphoneTrack = null;
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
        setState(() {
          cameraRenderer = null;
        });

        if (callType == "GROUP") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConferenceMeetingScreen(
                token: _token,
                meetingId: _meetingID,
                displayName: displayName,
                micEnabled: isMicOn,
                camEnabled: isCameraOn,
                selectedAudioOutputDevice: selectedAudioOutputDevice,
                selectedAudioInputDevice: selectedAudioInputDevice,
                cameraTrack: cameraTrack,
                micTrack: microphoneTrack,
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
                  selectedAudioOutputDevice: selectedAudioOutputDevice,
                  selectedAudioInputDevice: selectedAudioInputDevice,
                  cameraTrack: cameraTrack,
                  micTrack: microphoneTrack),
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

        if (callType == "GROUP") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConferenceMeetingScreen(
                  token: _token,
                  meetingId: meetingId,
                  displayName: displayName,
                  micEnabled: isMicOn,
                  camEnabled: isCameraOn,
                  selectedAudioOutputDevice: selectedAudioOutputDevice,
                  selectedAudioInputDevice: selectedAudioInputDevice,
                  cameraTrack: cameraTrack,
                  micTrack: microphoneTrack),
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
                  selectedAudioOutputDevice: selectedAudioOutputDevice,
                  selectedAudioInputDevice: selectedAudioInputDevice,
                  cameraTrack: cameraTrack,
                  micTrack: microphoneTrack),
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
    super.dispose();
  }
}
