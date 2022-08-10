import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:videosdk/videosdk.dart';
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

    log("Meeting Data: ${widget.meetingId} ${widget.token}");
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: _joined
          ? Scaffold(
              backgroundColor:
                  Theme.of(context).backgroundColor.withOpacity(0.8),
              floatingActionButton: MeetingActionBar(
                isMicEnabled: audioStream != null,
                isCamEnabled: videoStream != null,
                isScreenShareEnabled: shareStream != null,
                isScreenShareButtonDisabled:
                    remoteParticipantShareStream != null,
                // Called when Call End button is pressed
                onCallEndButtonPressed: () {
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
                // Called when switch camera button is pressed
                onSwitchCameraButtonPressed: () {
                  final selectedCamId = meeting.selectedCamId;

                  MediaDeviceInfo deviceToSwitch = cameras.firstWhere(
                    (cam) => cam.deviceId != selectedCamId,
                  );

                  meeting.changeCam(deviceToSwitch.deviceId);
                },

                // Called when ScreenShare button is pressed
                onScreenShareButtonPressed: () {
                  if (shareStream != null) {
                    meeting.disableScreenShare();
                  } else {
                    meeting.enableScreenShare();
                  }
                },

                // Called when more options button is pressed
                onMoreButtonPressed: () {
                  // Showing more options dialog box
                  showDialog<void>(
                    context: navigatorKey.currentContext!,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("More options"),
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Chat
                          ElevatedButton(
                            child: const Text('Chat'),
                            onPressed: () {
                              Navigator.pop(context);
                              showModalBottomSheet(
                                context: context,
                                constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height -
                                            statusbarHeight),
                                isScrollControlled: true,
                                builder: (context) =>
                                    ChatScreen(meeting: meeting),
                              );
                            },
                          ),

                          // Recording button
                          ElevatedButton(
                            child: Text(
                              isRecordingOn
                                  ? 'Stop Recording'
                                  : 'Start Recording',
                            ),
                            onPressed: () {
                              if (isRecordingOn) {
                                meeting.stopRecording();
                              } else {
                                meeting.startRecording(recordingWebHookURL);
                              }

                              Navigator.pop(context);
                            },
                          ),

                          // LiveStream button
                          ElevatedButton(
                            child: Text(
                              isLiveStreamOn
                                  ? 'Stop Livestream'
                                  : 'Start Livestream',
                            ),
                            onPressed: () {
                              List liveStreamOptions = [];

                              if (isLiveStreamOn) {
                                meeting.stopLivestream();
                              } else {
                                if (liveStreamOptions.isNotEmpty) {
                                  meeting.startLivestream(liveStreamOptions);
                                } else {
                                  toastMsg(
                                    "Failed to start livestream. Please add live stream options.",
                                  );
                                }
                              }

                              Navigator.pop(context);
                            },
                          ),

                          ElevatedButton(
                            child: const Text('Low Resolution'),
                            onPressed: () {
                              meeting.participants.forEach((key, value) {
                                value.setQuality('low');
                              });

                              Navigator.pop(context);
                            },
                          ),

                          ElevatedButton(
                            child: const Text('Med Resolution'),
                            onPressed: () {
                              meeting.participants.forEach((key, value) {
                                value.setQuality('med');
                              });

                              Navigator.pop(context);
                            },
                          ),

                          ElevatedButton(
                            child: const Text('High Resolution'),
                            onPressed: () {
                              meeting.participants.forEach((key, value) {
                                value.setQuality('high');
                              });

                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              appBar: AppBar(
                title: Text(widget.meetingId),
                actions: [
                  // Recording status
                  if (isRecordingOn)
                    SvgPicture.asset("assets/recording_on.svg"),

                  // Copy meeting id button
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.meetingId));
                      toastMsg("Meeting ID has been copied.");
                    },
                  ),
                ],
              ),
              body: Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: Column(
                    children: [
                      if (remoteParticipantShareStream != null ||
                          shareStream != null)
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            color: Colors.black,
                            child: RTCVideoView(
                              remoteParticipantShareStream != null
                                  ? remoteParticipantShareStream!.renderer!
                                  : shareStream!.renderer!,
                            ),
                          ),
                        ),
                      Expanded(
                        child: ParticipantGridView(meeting: meeting),
                      ),
                    ],
                  )))
          : Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    VerticalSpacer(10),
                    Text("waiting to join meeting"),
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
        setState(() {
          meeting = _meeting;
          _joined = true;
        });

        // Holds available cameras info
        cameras = _meeting.getCameras();
      },
    );

    // Called when meeting is ended
    _meeting.on(Events.roomLeft, () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StartupScreen()),
          (route) => false);
    });

    // Called when recording is started
    _meeting.on(Events.recordingStarted, () {
      toastMsg("Meeting recording started.");

      setState(() {
        isRecordingOn = true;
      });
    });

    // Called when recording is stopped
    _meeting.on(Events.recordingStopped, () {
      toastMsg("Meeting recording stopped.");

      setState(() {
        isRecordingOn = false;
      });
    });

    // Called when LiveStreaming is started
    _meeting.on(Events.liveStreamStarted, () {
      toastMsg("Meeting live streaming started.");

      setState(() {
        isLiveStreamOn = true;
      });
    });

    // Called when LiveStreaming is stopped
    _meeting.on(Events.liveStreamStopped, () {
      toastMsg("Meeting live streaming stopped.");

      setState(() {
        isLiveStreamOn = false;
      });
    });

    // Called when mic is requested
    _meeting.on(Events.micRequested, (_data) {
      log("_data => $_data");
      dynamic accept = _data['accept'];
      dynamic reject = _data['reject'];

      log("accept => $accept reject => $reject");

      // Mic Request Dialog
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text("Mic requested?"),
          content: const Text("Do you want to turn on your mic? "),
          actions: [
            TextButton(
              onPressed: () {
                reject();

                Navigator.of(context).pop();
              },
              child: const Text("Reject"),
            ),
            TextButton(
              onPressed: () {
                accept();

                Navigator.of(context).pop();
              },
              child: const Text("Accept"),
            ),
          ],
        ),
      );
    });

    // Called when camera is requested
    _meeting.on(Events.cameraRequested, (_data) {
      log("_data => $_data");
      dynamic accept = _data['accept'];
      dynamic reject = _data['reject'];

      log("accept => $accept reject => $reject");

      // camera Request Dialog
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text("Camera requested?"),
          content: const Text("Do you want to turn on your Camera? "),
          actions: [
            TextButton(
              onPressed: () {
                reject();

                Navigator.of(context).pop();
              },
              child: const Text("Reject"),
            ),
            TextButton(
              onPressed: () {
                accept();

                Navigator.of(context).pop();
              },
              child: const Text("Accept"),
            ),
          ],
        ),
      );
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

    //Entry Event
    _meeting.on(Events.entryRequested, (data) {
      // var participantId = data['participantId'];
      var name = data["name"];
      var allow = data["allow"];
      var deny = data["deny"];

      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text("Join Request"),
          content: Text("Do you want to allow $name to join meeting?"),
          actions: [
            TextButton(
              onPressed: () {
                deny();
                Navigator.of(context).pop();
              },
              child: const Text("Deny"),
            ),
            TextButton(
              onPressed: () {
                allow();

                Navigator.of(context).pop();
              },
              child: const Text("Allow"),
            ),
          ],
        ),
      );
    });

    _meeting.on(Events.entryResponded, (data) {
      var id = data['id'];
      var decision = data['decision'];
      if (id == _meeting.localParticipant.id) {
        if (decision == 'allowed') {
          toastMsg("Allowed to join the meeting.");
        } else {
          toastMsg("Denied to join the meeting.");
          Navigator.of(context).pop();
        }
      }
    });
  }

  Future<bool> _onWillPopScope() async {
    meeting.leave();
    return true;
  }
}
