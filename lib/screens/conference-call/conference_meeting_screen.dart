import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/screens/common/join_screen.dart';
import 'package:videosdk_flutter_example/utils/toast.dart';
import 'package:videosdk_flutter_example/widgets/common/app_bar/meeting_appbar.dart';
import 'package:videosdk_flutter_example/widgets/common/chat/chat_view.dart';
import 'package:videosdk_flutter_example/widgets/common/joining/waiting_to_join.dart';
import 'package:videosdk_flutter_example/widgets/common/meeting_controls/meeting_action_bar.dart';
import 'package:videosdk_flutter_example/widgets/common/participant/participant_list.dart';
import 'package:videosdk_flutter_example/widgets/conference-call/conference_participant_grid.dart';
import 'package:videosdk_flutter_example/widgets/conference-call/conference_screenshare_view.dart';

class ConferenceMeetingScreen extends StatefulWidget {
  final String meetingId, token, displayName;
  final bool micEnabled, camEnabled, chatEnabled;
  final MicrophoneDeviceInfo? selectedAudioOutputDevice, selectedAudioInputDevice;

  final CustomStreamTrack? cameraTrack;
  final CustomStreamTrack? micTrack;

  const ConferenceMeetingScreen(
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
  State<ConferenceMeetingScreen> createState() =>
      _ConferenceMeetingScreenState();
}

class _ConferenceMeetingScreenState extends State<ConferenceMeetingScreen> {
  bool isRecordingOn = false;
  bool showChatSnackbar = true;
  String recordingState = "RECORDING_STOPPED";
  // Meeting
  late Room meeting;
  bool _joined = false;

  // Streams
  RTCStream? shareStream;
  RTCStream? videoStream;
  RTCStream? audioStream;
  RTCStream? remoteParticipantShareStream;

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
    Room room = VideoSDK.createRoom(
      roomId: widget.meetingId,
      token: widget.token,
      customCameraTrack: widget.cameraTrack,
      customMicrophoneTrack: widget.micTrack,
      participantName: widget.displayName,
      micEnabled: widget.micEnabled,
      camEnabled: widget.camEnabled,
      maxResolution: MaxResolution.HD,
    );

    // Register meeting events
    registerMeetingEvents(room);

    // Join meeting
    room.join().showErrors(context);
  }

  @override
  Widget build(BuildContext context) {
    //Get statusbar height
    final statusbarHeight = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: false,
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
                      MeetingAppBar(
                              meeting: meeting,
                              token: widget.token,
                              recordingState: recordingState,
                              isFullScreen: fullScreen,
                            ),
                      const Divider(),
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 8.0),
                        child: Flex(
                          direction: ResponsiveValue<Axis>(context,
                              conditionalValues: [
                                Condition.equals(
                                    name: MOBILE, value: Axis.vertical),
                                Condition.largerThan(
                                    name: MOBILE, value: Axis.horizontal),
                              ]).value!,
                          children: [
                            ConferenseScreenShareView(meeting: meeting),
                            Expanded(
                              child:
                                  ConferenceParticipantGrid(meeting: meeting),
                            ),
                          ],
                        ),
                      )),
                      Column(
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
                                      meeting.end().showErrors(context);
                                    },

                                    onCallLeaveButtonPressed: () {
                                      meeting.leave().showErrors(context);
                                    },
                                    // Called when mic button is pressed
                                    onMicButtonPressed: () {
                                      if (audioStream != null) {
                                        meeting.muteMic().showErrors(context);
                                      } else {
                                        meeting.unmuteMic().showErrors(context);
                                      }
                                    },
                                    // Called when camera button is pressed
                                    onCameraButtonPressed: () {
                                      if (videoStream != null) {
                                        meeting.disableCam().showErrors(context);
                                      } else {
                                        meeting.enableCam().showErrors(context);
                                      }
                                    },

                                    onSwitchMicButtonPressed: (details) async {
                                      List<MicrophoneDeviceInfo>? outputDevice =
                                          await VideoSDK.getMics();

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
                                            padding: EdgeInsets.zero,
                                            value: e,
                                            child: Container(
                                              color: e.deviceId ==
                                                      VideoSDK.getSelectedAudioDevice()
                                                          ?.deviceId
                                                  ? Color.fromRGBO(
                                                      109, 110, 113, 1)
                                                  : Colors.transparent,
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      16,
                                                      10,
                                                      5,
                                                      10), // Ensure no padding
                                                  child: Text(e.label),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        elevation: 8.0,
                                      ).then((value) {
                                        if (value != null) {
                                          meeting.setAudioDevice(value);
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
                                      ).whenComplete(() => {
                                            setState(() {
                                              showChatSnackbar = true;
                                            })
                                          });
                                    },

                                    // Called when more options button is pressed
                                    onMoreOptionSelected: (option) {
                                      // Showing more options dialog box
                                      if (option == "screenshare") {
                                        if (remoteParticipantShareStream ==
                                            null) {
                                          if (shareStream == null) {
                                            meeting.enableScreenShare().showErrors(context);
                                          } else {
                                            meeting.disableScreenShare().showErrors(context);
                                          }
                                        } else {
                                          showSnackBarMessage(
                                              message:
                                                  "Someone is already presenting",
                                              context: context);
                                        }
                                      } else if (option == "recording") {
                                        print("⏺️ [RECORDING ACTION TRIGGERED] current recordingState = $recordingState");
                                        if (recordingState ==
                                            "RECORDING_STOPPING") {
                                          showSnackBarMessage(
                                              message:
                                                  "Recording is in stopping state",
                                              context: context);
                                        } else if (recordingState ==
                                            "RECORDING_STARTED") {
                                          meeting.stopRecording().showErrors(context);
                                        } else if (recordingState ==
                                            "RECORDING_STARTING") {
                                          showSnackBarMessage(
                                              message:
                                                  "Recording is in starting state",
                                              context: context);
                                        } else {
                                          meeting.startRecording().showErrors(context);
                                        }
                                      } else if (option == "participants") {
                                        showModalBottomSheet(
                                          context: context,
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
          : const WaitingToJoin(),
    );
  }

  void registerMeetingEvents(Room _meeting) {
    // Called when joined in meeting
    _meeting.on(
      Events.roomJoined,
      () {
        setState(() {
          meeting = _meeting;
          _joined = true;
        });


        subscribeToChatMessages(_meeting);
      },
    );

    // Called when meeting is ended
    _meeting.on(Events.roomLeft, (LeaveReason? reason) {
      if (reason != null && reason != LeaveReason.MANUAL_LEAVE_CALLED) {
        showSnackBarMessage(
            message: "Meeting left due to ${reason.message} !!",
            context: context);
      }
      if (!mounted) return;
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
    _meeting.localParticipant.on(Events.streamEnabled, (RTCStream _stream) {
      if (_stream.kind == MediaType.VIDEO) {
        setState(() {
          videoStream = _stream;
        });
      } else if (_stream.kind == MediaType.AUDIO) {
        setState(() {
          audioStream = _stream;
        });
      } else if (_stream.kind == MediaType.SHARE) {
        setState(() {
          shareStream = _stream;
        });
      }
    });

    // Called when stream is disabled
    _meeting.localParticipant.on(Events.streamDisabled, (RTCStream _stream) {
      if (_stream.kind == MediaType.VIDEO && videoStream?.id == _stream.id) {
        setState(() {
          videoStream = null;
        });
      } else if (_stream.kind == MediaType.AUDIO && audioStream?.id == _stream.id) {
        setState(() {
          audioStream = null;
        });
      } else if (_stream.kind == MediaType.SHARE && shareStream?.id == _stream.id) {
        setState(() {
          shareStream = null;
        });
      }
    });

    // Called when presenter is changed
    _meeting.on(Events.presenterChanged, (_activePresenterId) {
      Participant? activePresenterParticipant =
          _meeting.participants[_activePresenterId];

      // Get Share Stream
      RTCStream? _stream = activePresenterParticipant?.streams.values
          .singleWhere((e) => e.kind == MediaType.SHARE);

      setState(() => remoteParticipantShareStream = _stream);
    });

    _meeting.on(
        Events.error,
        (VideoSDKError error) => showSnackBarMessage(
            message: "${error.name} :: ${error.message}", context: context));
  }

  void subscribeToChatMessages(Room meeting) {
    meeting.pubSub
        .subscribe(
            "CHAT",
            PubSubMessageListener(onMessageReceived: (message) {
          if (message.senderId != meeting.localParticipant.id) {
            if (mounted) {
              if (showChatSnackbar) {
                showSnackBarMessage(
                    message: message.senderName + ": " + message.message,
                    context: context);
              }
            }
          }
    }))
        .catchError((Object e) {
      log("Subscribe failed: $e");
    });
  }

  Future<bool> _onWillPopScope() async {
    meeting.leave().showErrors(context);
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
