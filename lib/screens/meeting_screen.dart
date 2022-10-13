import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/widgets/one_to_one_participant_view/participant_view_one_to_one.dart';
import 'package:videosdk_flutter_example/widgets/participant/participant_list.dart';
import '/screens/chat_screen.dart';

import '../../navigator_key.dart';
import '../utils/spacer.dart';
import '../utils/toast.dart';
import '../widgets/meeting_controls/meeting_action_bar.dart';
import '../widgets/participant_grid_view/participant_grid_view.dart';
import 'startup_screen.dart';

// Meeting Screen
class MeetingScreen extends StatefulWidget {
  final String meetingId, token, displayName;
  final bool micEnabled, camEnabled, chatEnabled;
  const MeetingScreen({
    Key? key,
    required this.meetingId,
    required this.token,
    required this.displayName,
    this.micEnabled = true,
    this.camEnabled = true,
    this.chatEnabled = true,
  }) : super(key: key);

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  // Recording Webhook
  final String recordingWebHookURL = "";

  // Meeting
  late Room meeting;
  bool _joined = false;
  bool _moreThan2Participants = false;

  // control states
  bool isRecordingOn = false;
  bool isLiveStreamOn = false;

  // List of controls
  List<MediaDeviceInfo> cameras = [];
  List<MediaDeviceInfo> mics = [];
  String? selectedMicId;

  String? activePresenterId;

  // Streams
  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;
  Stream? remoteParticipantShareStream;

  Duration? elapsedTime;

  Timer? sessionTimer;

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
    // Create instance of Room (Meeting)
    Room room = VideoSDK.createRoom(
      roomId: widget.meetingId,
      token: widget.token,
      displayName: widget.displayName,
      micEnabled: widget.micEnabled,
      camEnabled: widget.camEnabled,
      maxResolution: 'hd',
      defaultCameraIndex: 1,
      notification: const NotificationInfo(
        title: "Video SDK",
        message: "Video SDK is sharing screen in the meeting",
        icon: "notification_share", // drawable icon name
      ),
    );

    // Register meeting events
    registerMeetingEvents(room);

    // Join meeting
    room.join();
  }

  @override
  Widget build(BuildContext context) {
    //Get statusbar height
    final statusbarHeight = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: _joined
          ? Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  AnimatedCrossFade(
                    duration: Duration(milliseconds: 500),
                    crossFadeState: !fullScreen
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    secondChild: SizedBox.shrink(),
                    firstChild: AppBar(
                      automaticallyImplyLeading: false,
                      title: Row(
                        children: [
                          if (isRecordingOn)
                            Lottie.asset('assets/recording_lottie.json',
                                height: statusbarHeight),
                          if (isRecordingOn) HorizontalSpacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.meetingId,
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
                                      Clipboard.setData(ClipboardData(
                                          text: widget.meetingId));
                                      showSnackBarMessage(
                                          message:
                                              "Meeting ID has been copied.",
                                          context: context);
                                    },
                                  ),
                                ],
                              ),
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
                                (camera) =>
                                    camera.deviceId != meeting.selectedCamId);
                            meeting.changeCam(newCam.deviceId);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                        onDoubleTap: () => {
                              setState(() {
                                fullScreen = !fullScreen;
                              })
                            },
                        child: ParticipantViewOneToOne(meeting: meeting)),
                  ),
                  AnimatedCrossFade(
                    duration: Duration(milliseconds: 500),
                    crossFadeState: !fullScreen
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    secondChild: SizedBox.shrink(),
                    firstChild: MeetingActionBar(
                      isMicEnabled: audioStream != null,
                      isCamEnabled: videoStream != null,
                      isScreenShareEnabled: shareStream != null,
                      isRecordingOn: isRecordingOn,
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
                        List<MediaDeviceInfo> outptuDevice =
                            meeting.getAudioOutputDevices();
                        await showMenu(
                          context: context,
                          color: black700,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          position: RelativeRect.fromLTRB(
                              details.globalPosition.dx,
                              details.globalPosition.dy - 145,
                              100,
                              100),
                          items: outptuDevice.map((e) {
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
                        showModalBottomSheet(
                          context: context,
                          constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height -
                                  statusbarHeight),
                          isScrollControlled: true,
                          builder: (context) => ChatScreen(meeting: meeting),
                        );
                      },

                      // Called when more options button is pressed
                      onMoreOptionSelected: (option) {
                        // Showing more options dialog box
                        if (option == "screenshare") {
                          if (remoteParticipantShareStream == null) {
                            if (shareStream == null) {
                              meeting.enableScreenShare();
                            } else {
                              meeting.disableScreenShare();
                            }
                          } else {
                            showSnackBarMessage(
                                message: "Someone is already presenting",
                                context: context);
                          }
                        } else if (option == "recording") {
                          if (isRecordingOn) {
                            meeting.stopRecording();
                          } else {
                            meeting.startRecording("");
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
              ))
          : _moreThan2Participants
              ? Scaffold(
                  backgroundColor: Theme.of(context).primaryColor,
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "OOPS!!",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700),
                        ),
                        const VerticalSpacer(20),
                        const Text(
                          "Maximun 2 participants can join this meeting",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        const VerticalSpacer(10),
                        const Text(
                          "Please try again later",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                        const VerticalSpacer(20),
                        MaterialButton(
                          onPressed: () {
                            meeting.leave();
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: purple,
                          child:
                              const Text("Ok", style: TextStyle(fontSize: 16)),
                        )
                      ],
                    ),
                  ),
                )
              : Scaffold(
                  backgroundColor: Theme.of(context).primaryColor,
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset("assets/joining_lottie.json", width: 100),
                        const VerticalSpacer(20),
                        const Text("Creating a Room",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
    );
  }

  void registerMeetingEvents(Room _meeting) {
    // Called when joined in meeting
    _meeting.on(
      Events.roomJoined,
      () {
        if (_meeting.participants.length > 1) {
          setState(() {
            meeting = _meeting;
            _moreThan2Participants = true;
          });
        } else {
          setState(() {
            meeting = _meeting;
            _joined = true;
          });

          subscribeToChatMessages(_meeting);
          startTimer();
          // Holds available cameras info
          cameras = _meeting.getCameras();
        }
      },
    );

    // Called when meeting is ended
    _meeting.on(Events.roomLeft, (String? errorMsg) {
      if (errorMsg != null) {
        showSnackBarMessage(
            message: "Meeting left due to $errorMsg !!", context: context);
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StartupScreen()),
          (route) => false);
    });

    // Called when recording is started
    _meeting.on(Events.recordingStarted, () {
      showSnackBarMessage(
          message: "Meeting recording started", context: context);

      setState(() {
        isRecordingOn = true;
      });
    });

    // Called when recording is stopped
    _meeting.on(Events.recordingStopped, () {
      showSnackBarMessage(
          message: "Meeting recording stopped", context: context);

      setState(() {
        isRecordingOn = false;
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
          _meeting.participants[_activePresenterId];

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
                  if (_meeting.participants.length < 2)
                    {
                      setState(() {
                        _joined = true;
                        _moreThan2Participants = false;
                      }),
                      subscribeToChatMessages(_meeting),
                      startTimer()
                    }
                }
            });
  }

  void subscribeToChatMessages(Room meeting) {
    meeting.pubSub.subscribe("CHAT", (message) {
      if (message.senderId != meeting.localParticipant.id) {
        if (mounted) {
          showSnackBarMessage(
              message: message.senderName + ": " + message.message,
              context: context);
        }
      }
    });
  }

  Future<void> startTimer() async {
    final String? _VIDEOSDK_API_ENDPOINT = dotenv.env['VIDEOSDK_API_ENDPOINT'];

    final Uri getMeetingIdUrl = Uri.parse(
        '$_VIDEOSDK_API_ENDPOINT/sessions?roomId=${widget.meetingId}');
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

  Future<bool> _onWillPopScope() async {
    if (sessionTimer != null) {
      sessionTimer!.cancel();
    }
    meeting.leave();
    return true;
  }
}
