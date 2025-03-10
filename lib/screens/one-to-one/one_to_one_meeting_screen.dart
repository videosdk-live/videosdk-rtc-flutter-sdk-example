import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/widgets/common/app_bar/web_meeting_appbar.dart';
import 'package:videosdk_flutter_example/widgets/common/joining/participant_limit_reached.dart';
import 'package:videosdk_flutter_example/widgets/common/joining/waiting_to_join.dart';
import 'package:videosdk_flutter_example/widgets/common/app_bar/meeting_appbar.dart';
import 'package:videosdk_flutter_example/widgets/one-to-one/one_to_one_meeting_container.dart';
import 'package:videosdk_flutter_example/widgets/common/participant/participant_list.dart';
import '../../widgets/common/chat/chat_view.dart';

import '../../utils/toast.dart';
import '../../widgets/common/meeting_controls/meeting_action_bar.dart';
import '../../widgets/common/screen_share/screen_select_dialog.dart';
import '../common/join_screen.dart';
import 'package:videosdk_webrtc/flutter_webrtc.dart';

// Meeting Screen
class OneToOneMeetingScreen extends StatefulWidget {
  final String meetingId, token, displayName;
  final bool micEnabled, camEnabled, chatEnabled;
  final AudioDeviceInfo? selectedAudioOutputDevice, selectedAudioInputDevice;
  final CustomTrack? cameraTrack;
  final CustomTrack? micTrack;

  const OneToOneMeetingScreen(
      {Key? key,
      required this.meetingId,
      required this.token,
      required this.displayName,
      this.micEnabled = true,
      this.camEnabled = true,
      this.chatEnabled = true,
      this.selectedAudioOutputDevice,
      this.selectedAudioInputDevice,
      this.cameraTrack,
      this.micTrack})
      : super(key: key);

  @override
  _OneToOneMeetingScreenState createState() => _OneToOneMeetingScreenState();
}

class _OneToOneMeetingScreenState extends State<OneToOneMeetingScreen> {
  static const platform = MethodChannel('com.example.example/channel');
  bool isRecordingOn = false;
  bool showChatSnackbar = true;
  String recordingState = "RECORDING_STOPPED";
  // Meeting
  late Room meeting;
  bool _joined = false;
  bool _moreThan2Participants = false;

  // Streams
  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;
  Stream? remoteParticipantShareStream;

  bool fullScreen = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Create instance of Room (Meeting)
    meeting = VideoSDK.createRoom(
      roomId: widget.meetingId,
      token: widget.token,
      displayName: widget.displayName,
      micEnabled: widget.micEnabled,
      camEnabled: widget.camEnabled,
      maxResolution: 'hd',
      multiStream: false,
      customCameraVideoTrack: widget.cameraTrack,
      customMicrophoneAudioTrack: widget.micTrack,
      notification: const NotificationInfo(
        title: "Video SDK",
        message: "Video SDK is sharing screen in the meeting",
        icon: "notification_share", // drawable icon name
      ),
    );

    // Register meeting events
    registerMeetingEvents(meeting);

    // Join meeting
    meeting.join();
  }

  Future<void> _startMicrophoneService() async {
    try {
      await platform.invokeMethod('startMicrophoneService');
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }

  Future<void> _stopMicrophoneService() async {
    try {
      await platform.invokeMethod('stopMicrophoneService');
    } on PlatformException catch (e) {
      print("Failed to stop service: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    //Get statusbar height
    final statusbarHeight = MediaQuery.of(context).padding.top;
    bool isWebMobile = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        _onWillPopScope();
      },
      child: _joined
          ? SafeArea(
              child: Scaffold(
                  backgroundColor: Theme.of(context).primaryColor,
                  body: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      !isWebMobile &&
                              (kIsWeb || Platform.isMacOS || Platform.isWindows)
                          ? WebMeetingAppBar(
                              meeting: meeting,
                              token: widget.token,
                              recordingState: recordingState,
                              isMicEnabled: audioStream != null,
                              isCamEnabled: videoStream != null,
                              isLocalScreenShareEnabled: shareStream != null,
                              isRemoteScreenShareEnabled:
                                  remoteParticipantShareStream != null,
                            )
                          : MeetingAppBar(
                              meeting: meeting,
                              token: widget.token,
                              recordingState: recordingState,
                              isFullScreen: fullScreen,
                            ),
                      const Divider(),
                      Expanded(
                        child: GestureDetector(
                            onDoubleTap: () => {
                                  setState(() {
                                    fullScreen = !fullScreen;
                                  })
                                },
                            child: OneToOneMeetingContainer(meeting: meeting)),
                      ),
                      !isWebMobile &&
                              (kIsWeb || Platform.isMacOS || Platform.isWindows)
                          ? Container()
                          : Column(
                              children: [
                                const Divider(),
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 300),
                                  crossFadeState: !fullScreen
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  secondChild: const SizedBox.shrink(),
                                  firstChild: MeetingActionBar(
                                    isMicEnabled: audioStream != null,
                                    isCamEnabled: videoStream != null,
                                    isScreenShareEnabled: shareStream != null,
                                    recordingState: recordingState,
                                    // Called when Call End button is pressed
                                    onCallEndButtonPressed: () {
                                      meeting.end();
                                    },

                                    onCallLeaveButtonPressed: () {
                                      meeting.leave();
                                    },
                                    // Called when mic button is pressed
                                    onMicButtonPressed: () {
                                      if (audioStream != null) {
                                        meeting.muteMic();
                                      } else {
                                        meeting.unmuteMic();
                                      }
                                    },
                                    // Called when camera button is pressed
                                    onCameraButtonPressed: () {
                                      if (videoStream != null) {
                                        meeting.disableCam();
                                      } else {
                                        meeting.enableCam();
                                      }
                                    },

                                    onSwitchMicButtonPressed: (details) async {
                                      List<AudioDeviceInfo>? outputDevice =
                                          await VideoSDK.getAudioDevices();
                                      double bottomMargin =
                                          (70.0 * outputDevice!.length);
                                      final screenSize =
                                          MediaQuery.of(context).size;
                                      await showMenu(
                                        context: context,
                                        color: black700,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        position: RelativeRect.fromLTRB(
                                          screenSize.width -
                                              details.globalPosition.dx,
                                          details.globalPosition.dy -
                                              bottomMargin,
                                          details.globalPosition.dx,
                                          (bottomMargin),
                                        ),
                                        items: outputDevice.map((e) {
                                          return PopupMenuItem(
                                              value: e, child: Text(e.label));
                                        }).toList(),
                                        elevation: 8.0,
                                      ).then((value) {
                                        if (value != null) {
                                          meeting.switchAudioDevice(value);
                                        }
                                      });
                                    },

                                    onChatButtonPressed: () {
                                      setState(() {
                                        showChatSnackbar = false;
                                      });
                                      showModalBottomSheet(
                                        context: context,
                                        constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height -
                                                statusbarHeight),
                                        isScrollControlled: true,
                                        builder: (context) => ChatView(
                                            key: const Key("ChatScreen"),
                                            meeting: meeting),
                                      ).whenComplete(() {
                                        setState(() {
                                          showChatSnackbar = true;
                                        });
                                      });
                                    },

                                    // Called when more options button is pressed
                                    onMoreOptionSelected: (option) {
                                      // Showing more options dialog box
                                      if (option == "screenshare") {
                                        if (remoteParticipantShareStream ==
                                            null) {
                                          if (shareStream == null) {
                                            meeting.enableScreenShare();
                                          } else {
                                            meeting.disableScreenShare();
                                          }
                                        } else {
                                          showSnackBarMessage(
                                              message:
                                                  "Someone is already presenting",
                                              context: context);
                                        }
                                      } else if (option == "recording") {
                                        if (recordingState ==
                                            "RECORDING_STOPPING") {
                                          showSnackBarMessage(
                                              message:
                                                  "Recording is in stopping state",
                                              context: context);
                                        } else if (recordingState ==
                                            "RECORDING_STARTED") {
                                          meeting.stopRecording();
                                        } else if (recordingState ==
                                            "RECORDING_STARTING") {
                                          showSnackBarMessage(
                                              message:
                                                  "Recording is in starting state",
                                              context: context);
                                        } else {
                                          meeting.startRecording();
                                        }
                                      } else if (option == "participants") {
                                        showModalBottomSheet(
                                          context: context,
                                          // constraints: BoxConstraints(
                                          //     maxHeight: MediaQuery.of(context).size.height -
                                          //         statusbarHeight),
                                          isScrollControlled: false,
                                          builder: (context) =>
                                              ParticipantList(meeting: meeting),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ],
                  )),
            )
          : _moreThan2Participants
              ? ParticipantLimitReached(
                  meeting: meeting,
                )
              : const WaitingToJoin(),
    );
  }

  void registerMeetingEvents(Room _meeting) {
    // Called when joined in meeting
    _meeting.on(
      Events.roomJoined,
      () {
        if (meeting.participants.length > 1) {
          setState(() {
            meeting = _meeting;
            _moreThan2Participants = true;
          });
        } else {
          setState(() {
            meeting = _meeting;
            _joined = true;
          });
          _startMicrophoneService();
          if (kIsWeb || Platform.isWindows || Platform.isMacOS) {
            meeting.switchAudioDevice(widget.selectedAudioOutputDevice!);
          }
          subscribeToChatMessages(_meeting);
        }
      },
    );

    // Called when meeting is ended
    _meeting.on(Events.roomLeft, (String? errorMsg) {
      if (errorMsg != null) {
        showSnackBarMessage(
            message: "Meeting left due to $errorMsg !!", context: context);
      }
      _stopMicrophoneService();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const JoinScreen()),
          (route) => false);
    });

    // Called when recording is started
    _meeting.on(Events.recordingStateChanged, (String status) {
      showSnackBarMessage(
          message:
              "Meeting recording ${status == "RECORDING_STARTING" ? "is starting" : status == "RECORDING_STARTED" ? "started" : status == "RECORDING_STOPPING" ? "is stopping" : "stopped"}",
          context: context);

      setState(() {
        recordingState = status;
      });
    });

    // Called when stream is enabled
    _meeting.localParticipant.on(Events.streamEnabled, (Stream _stream) {
      if (_stream.kind == 'video') {
        setState(() {
          videoStream = _stream;
        });
      } else if (_stream.kind == 'audio') {
        setState(() {
          audioStream = _stream;
        });
      } else if (_stream.kind == 'share') {
        setState(() {
          shareStream = _stream;
        });
      }
    });

    // Called when stream is disabled
    _meeting.localParticipant.on(Events.streamDisabled, (Stream _stream) {
      if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
        setState(() {
          videoStream = null;
        });
      } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
        setState(() {
          audioStream = null;
        });
      } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
        setState(() {
          shareStream = null;
        });
      }
    });

    // Called when presenter is changed
    _meeting.on(Events.presenterChanged, (_activePresenterId) {
      Participant? activePresenterParticipant =
          meeting.participants[_activePresenterId];

      // Get Share Stream
      Stream? _stream = activePresenterParticipant?.streams.values
          .singleWhere((e) => e.kind == "share");

      setState(() => remoteParticipantShareStream = _stream);
    });

    _meeting.on(
        Events.participantLeft,
        (participant) => {
              if (_moreThan2Participants)
                {
                  if (meeting.participants.length < 2)
                    {
                      setState(() {
                        _joined = true;
                        _moreThan2Participants = false;
                      }),
                      subscribeToChatMessages(meeting),
                    }
                }
            });

    _meeting.on(
        Events.error,
        (error) => {
              showSnackBarMessage(
                  message: "${error['name']} :: ${error['message']}",
                  context: context)
            });
  }

  void subscribeToChatMessages(Room meeting) {
    meeting.pubSub.subscribe("CHAT", (message) {
      if (message.senderId != meeting.localParticipant.id) {
        if (mounted) {
          // print("navigator key");
          // print(navigatorKey.currentWidget?.key.toString());
          if (showChatSnackbar) {
            showSnackBarMessage(
                message: "${message.senderName}: ${message.message}",
                context: context);
          }
        }
      }
    });
  }

  Future<bool> _onWillPopScope() async {
    meeting.leave();
    return true;
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
