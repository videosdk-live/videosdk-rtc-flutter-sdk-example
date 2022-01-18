import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:videosdk/rtc.dart';
import '../utils/spacer.dart';

import '../../navigator_key.dart';
import '../utils/toast.dart';
import '../widgets/localParticipant/local_participant.dart';
import '../widgets/meeting_controls/meeting_action_bar.dart';
import '../widgets/remoteParticipants/list_remote_participants.dart';
import 'startup_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Meeting Screen
class MeetingScreen extends StatefulWidget {
  final String meetingId, token, displayName;
  final bool micEnabled, webcamEnabled;
  const MeetingScreen({
    Key? key,
    required this.meetingId,
    required this.token,
    required this.displayName,
    this.micEnabled = true,
    this.webcamEnabled = true,
  }) : super(key: key);

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  // Recording Webhook
  final String recordingWebHookURL = "";

  // LiveStream Configuration
  final List<Map<String, dynamic>> liveStreams = [];

  Map<String, Participant> participants = {};
  Participant? localParticipant;
  Meeting? meeting;

  String? activeSpeakerId;
  String? activePresenterId;

  // control states
  bool isRecordingOn = false;
  bool isLiveStreamOn = false;

  // List of controls
  List<MediaDeviceInfo> webcams = [];
  List<MediaDeviceInfo> mics = [];
  String? selectedMicId;

  // Streams
  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;

  @override
  Widget build(BuildContext context) {
    log("Meeting Data: ${widget.meetingId} ${widget.token}");
    return MeetingBuilder(
      meetingId: widget.meetingId,
      displayName: widget.displayName,
      token: widget.token,
      micEnabled: widget.micEnabled,
      webcamEnabled: widget.webcamEnabled,
      builder: (_meeting) {
        // Called when joined in meeting
        _meeting.on(
          "meeting-joined",
          () {
            setState(() {
              localParticipant = _meeting.localParticipant;
              meeting = _meeting;
            });

            // Setting meeting event listeners
            setMeetingListeners(_meeting);

            // Holds available webcams info
            webcams = _meeting.getWebcams();
          },
        );

        // Showing waiting screen
        if (meeting == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  verticalSpacer(10),
                  const Text("waiting to join meeting"),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor.withOpacity(0.8),
          floatingActionButton: MeetingActionBar(
            isMicEnabled: audioStream != null,
            isWebcamEnabled: videoStream != null,
            // Called when Call End button is pressed
            onCallEndButtonPressed: () {
              _meeting.leave();
            },
            // Called when mic button is pressed
            onMicButtonPressed: () {
              if (audioStream != null) {
                _meeting.muteMic();
              } else {
                _meeting.unmuteMic();
              }
            },
            // Called when webcam button is pressed
            onWebcamButtonPressed: () {
              if (videoStream != null) {
                _meeting.disableWebcam();
              } else {
                _meeting.enableWebcam();
              }
            },
            // Called when switch webcam button is pressed
            onSwitchCameraButtonPressed: () {
              final selectedWebcamId = _meeting.selectedWebcamId;

              MediaDeviceInfo deviceToSwitch = webcams.firstWhere(
                (webcam) => webcam.deviceId != selectedWebcamId,
              );

              _meeting.changeWebcam(deviceToSwitch.deviceId);
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
                      // Recording button
                      ElevatedButton(
                        child: Text(
                          isRecordingOn ? 'Stop Recording' : 'Start Recording',
                        ),
                        onPressed: () {
                          // validation
                          if (recordingWebHookURL.isEmpty) {
                            toastMsg("Please set webhook URL");
                            Navigator.pop(context);
                            return;
                          }
                          if (isRecordingOn) {
                            _meeting.stopRecording();
                          } else {
                            _meeting.startRecording(recordingWebHookURL);
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
                          // validation
                          if (liveStreams.isEmpty) {
                            toastMsg("Please set configuration for LiveStream");
                            Navigator.pop(context);
                            return;
                          }
                          if (isLiveStreamOn) {
                            _meeting.stopLivestream();
                          } else {
                            _meeting.startLivestream(liveStreams);
                          }

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
              if (isRecordingOn) SvgPicture.asset("assets/recording_on.svg"),

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
          body: Stack(
            children: [
              Column(
                children: [
                  if (participants.isNotEmpty)
                    Expanded(
                      child: ListRemoteParticipants(
                        participants: participants,
                      ),
                    )
                  else
                    const Expanded(
                      child: Center(
                        child: Text("No participants."),
                      ),
                    ),
                ],
              ),
              LocalParticipant(
                localParticipant: localParticipant!,
                meeting: meeting!,
              )
            ],
          ),
        );
      },
    );
  }

  void setMeetingListeners(Meeting meeting) {
    // Called when participant joined meeting
    meeting.on(
      "participant-joined",
      (Participant participant) {
        final newParticipants = participants;
        newParticipants[participant.id] = participant;
        setState(() {
          participants = newParticipants;
        });
      },
    );

    // Called when participant left meeting
    meeting.on(
      "participant-left",
      (participantId) {
        final newParticipants = participants;

        newParticipants.remove(participantId);
        setState(() {
          participants = newParticipants;
        });
      },
    );

    // Called when meeting is ended
    meeting.on('meeting-left', () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StartupScreen()),
          (route) => false);
    });

    // Called when speaker is changed
    meeting.on('speaker-changed', (_activeSpeakerId) {
      setState(() {
        activeSpeakerId = _activeSpeakerId;
      });
      log("meeting speaker-changed => $_activeSpeakerId");
    });

    // Called when presenter is changed
    meeting.on('presenter-changed', (_activePresenterId) {
      setState(() {
        activePresenterId = _activePresenterId;
      });
      log("meeting presenter-changed => $_activePresenterId");
    });

    // Called when recording is started
    meeting.on("recording-started", () {
      toastMsg("Meeting recording started.");

      setState(() {
        isRecordingOn = true;
      });
    });

    // Called when recording is stopped
    meeting.on("recording-stopped", () {
      toastMsg("Meeting recording stopped.");

      setState(() {
        isRecordingOn = false;
      });
    });

    // Called when LiveStreaming is started
    meeting.on("livestream-started", () {
      toastMsg("Meeting live streaming started.");

      setState(() {
        isLiveStreamOn = true;
      });
    });

    // Called when LiveStreaming is stopped
    meeting.on("livestream-stopped", () {
      toastMsg("Meeting live streaming stopped.");

      setState(() {
        isLiveStreamOn = false;
      });
    });

    // Called when mic is requested
    meeting.on("mic-requested", (_data) {
      log("_data => $_data");
      dynamic accept = _data['accept'];
      dynamic reject = _data['reject'];

      log("accept => $accept reject => $reject");

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

    // Called when webcam is requested
    meeting.on("webcam-requested", (_data) {
      log("_data => $_data");
      dynamic accept = _data['accept'];
      dynamic reject = _data['reject'];

      log("accept => $accept reject => $reject");

      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text("Webcam requested?"),
          content: const Text("Do you want to turn on your webcam? "),
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
    meeting.localParticipant.on("stream-enabled", (Stream _stream) {
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
    meeting.localParticipant.on("stream-disabled", (Stream _stream) {
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
  }
}
