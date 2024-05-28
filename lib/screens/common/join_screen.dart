// ignore_for_file: non_constant_identifier_names, dead_code
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
    disposeCameraPreview();
    initCameraPreview();
  }

  void checkBluetoothPermissions() async {
    bool bluetoothPerm = await VideoSDK.checkBluetoothPermission();
    if (bluetoothPerm != true) {
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
      if (!kIsWeb) {
        if (Platform.isAndroid || Platform.isIOS) {
          setState(() {
            selectedAudioOutputDevice = audioDevices?.first;
          });
        }
      } else {
        audioInputDevices = [];
        audioOutputDevices = [];
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
      Map<String, bool> permissions = await VideoSDK.checkPermissions();

      if (perm == Permissions.audio || perm == Permissions.audio_video) {
        if (permissions['audio'] != true) {
          Map<String, bool> reqPermissions =
              await VideoSDK.requestPermissions(Permissions.audio);
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

      if (perm == Permissions.video || perm == Permissions.audio_video) {
        if (permissions['video'] != true) {
          Map<String, bool> reqPermissions =
              await VideoSDK.requestPermissions(Permissions.video);

          setState(() => isCameraPermissionAllowed = reqPermissions['video']);
        } else {
          setState(() => isCameraPermissionAllowed = true);
        }
      }
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          checkBluetoothPermissions();
        }
      }

      getDevices();
    } catch (e) {
      print("error $e");
    }
  }

  void checkPermissions() async {
    Map<String, bool> permissions = await VideoSDK.checkPermissions();
    setState(() {
      isMicrophonePermissionAllowed = permissions['audio'];
      isCameraPermissionAllowed = permissions['video'];
      isMicOn = permissions['audio']!;
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
    final maxHeight = MediaQuery.of(context).size.height;
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
                        minHeight: viewportConstraints.maxHeight),
                    child: IntrinsicHeight(
                      child: kIsWeb
                          ? Container(
                              margin:
                                  const EdgeInsets.fromLTRB(40, 150, 40, 150),
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
                                                    ? setState(
                                                        () =>
                                                            isMicOn = !isMicOn,
                                                      )
                                                    : checkandReqPermissions(
                                                        Permissions.audio),
                                            onCameraToggle: () {
                                              isCameraPermissionAllowed !=
                                                          null &&
                                                      isCameraPermissionAllowed ==
                                                          true
                                                  ? {
                                                      if (isCameraOn)
                                                        {disposeCameraPreview()}
                                                      else
                                                        {initCameraPreview()},
                                                      setState(() =>
                                                          isCameraOn =
                                                              !isCameraOn)
                                                    }
                                                  : checkandReqPermissions(
                                                      Permissions.video);
                                            },
                                          ),
                                          kIsWeb
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
                                      margin:
                                          EdgeInsets.only(top: maxWidth / 10),
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
                                          isMicrophonePermissionAllowed !=
                                                      null &&
                                                  isMicrophonePermissionAllowed ==
                                                      true
                                              ? setState(
                                                  () => isMicOn = !isMicOn,
                                                )
                                              : checkandReqPermissions(
                                                  Permissions.audio),
                                      onCameraToggle: () {
                                        isCameraPermissionAllowed != null &&
                                                isCameraPermissionAllowed ==
                                                    true
                                            ? {
                                                if (isCameraOn)
                                                  {disposeCameraPreview()}
                                                else
                                                  {initCameraPreview()},
                                                setState(() =>
                                                    isCameraOn = !isCameraOn)
                                              }
                                            : checkandReqPermissions(
                                                Permissions.video);
                                      },
                                    ),
                                  ),
                                  JoinOptions(
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
                                  )
                                ]),
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
                  selectedAudioOutputDevice: selectedAudioOutputDevice,
                  selectedAudioInputDevice: selectedAudioInputDevice,
                  cameraTrack: cameraTrack),
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
                  selectedAudioOutputDevice: selectedAudioOutputDevice,
                  selectedAudioInputDevice: selectedAudioInputDevice,
                  cameraTrack: cameraTrack),
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
    //cameraTrack?.dispose();
    super.dispose();
  }
}
