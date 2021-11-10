// import 'package:example/ui/utils/dragger.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/meeting.dart';
import 'package:videosdk/participant.dart';
import 'package:videosdk/stream.dart';
import 'package:videosdk/rtc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MeetingActions extends StatefulWidget {
  final Participant localParticipant;
  final Meeting meeting;

  MeetingActions({
    Key? key,
    required this.localParticipant,
    required this.meeting,
  }) : super(key: key);

  @override
  MeetingActionsState createState() => MeetingActionsState();
}

class MeetingActionsState extends State<MeetingActions> {
  List<MediaDeviceInfo> webcams = [];
  List<MediaDeviceInfo> mics = [];
  String? selectedMicId;

  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;

  late bool isRecordingOn;
  late bool isLivestreamOn;

  @override
  initState() {
    _initListners();

    super.initState();

    selectedMicId = widget.meeting.selectedMicId;

    final _webcams = widget.meeting.getWebcams();

    webcams = _webcams;

    isRecordingOn = false;
    isLivestreamOn = false;
  }

  void toastMsg(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      // toastLength: Toast.LENGTH_LONG,
      // gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      // backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  _initListners() {
    widget.localParticipant.on(
      "stream-enabled",
      (Stream _stream) {
        if (_stream.kind == 'video') {
          setState(
            () {
              videoStream = _stream;
            },
          );
        } else if (_stream.kind == 'audio') {
          setState(
            () {
              audioStream = _stream;
            },
          );
        } else if (_stream.kind == 'share') {
          setState(
            () {
              shareStream = _stream;
            },
          );
        }
      },
    );

    widget.localParticipant.on(
      "stream-disabled",
      (Stream _stream) {
        if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
          setState(
            () {
              videoStream = null;
            },
          );
        } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
          setState(
            () {
              audioStream = null;
            },
          );
        } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
          setState(
            () {
              shareStream = null;
            },
          );
        }
      },
    );

    widget.meeting.on("recording-started", () {
      toastMsg("Meeting recording started.");

      setState(() {
        isRecordingOn = true;
      });
    });

    widget.meeting.on("recording-stopped", () {
      toastMsg("Meeting recording stopped.");

      setState(() {
        isRecordingOn = false;
      });
    });

    widget.meeting.on("livestream-started", () {
      toastMsg("Meeting live streaming started.");

      setState(() {
        isLivestreamOn = true;
      });
    });

    widget.meeting.on("livestream-stopped", () {
      toastMsg("Meeting live streaming stopped.");

      setState(() {
        isLivestreamOn = false;
      });
    });
  }

  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FloatingActionButton(
            backgroundColor: videoStream != null
                ? Colors.grey.shade800
                : Colors.grey.shade400,
            onPressed: videoStream != null
                ? () {
                    final selectedWebcamId = widget.meeting.selectedWebcamId;

                    MediaDeviceInfo deviceToSwitch = webcams.firstWhere(
                      (webcam) => webcam.deviceId != selectedWebcamId,
                    );

                    widget.meeting.changeWebcam(deviceToSwitch.deviceId);
                  }
                : null,
            child: const Icon(Icons.cameraswitch),
          ),
        ),
        Expanded(
          child: FloatingActionButton(
            onPressed: () {
              if (videoStream != null) {
                widget.meeting.disableWebcam();
              } else {
                widget.meeting.enableWebcam();
              }
            },
            backgroundColor: videoStream != null
                ? Colors.teal.shade600
                : Colors.teal.shade300,
            child: videoStream != null
                ? const Icon(Icons.videocam)
                : const Icon(Icons.videocam_off),
          ),
        ),
        Expanded(
          child: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () {
              widget.meeting.leave();
            },
            child: const Icon(Icons.call_end),
          ),
        ),
        Expanded(
          child: FloatingActionButton(
            onPressed: () {
              if (audioStream != null) {
                widget.meeting.muteMic();
              } else {
                widget.meeting.unmuteMic();
              }
            },
            backgroundColor: audioStream != null
                ? Colors.teal.shade600
                : Colors.teal.shade300,
            child: audioStream != null
                ? const Icon(Icons.mic)
                : const Icon(Icons.mic_off),
          ),
        ),
        Expanded(
          child: FloatingActionButton(
            backgroundColor: Colors.grey.shade800,
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ElevatedButton(
                            child: isRecordingOn
                                ? const Text('Stop Recording')
                                : const Text('Start Recording'),
                            onPressed: () {
                              if (isRecordingOn)
                                widget.meeting.stopRecording();
                              else
                                widget.meeting.startRecording("webhookUrl");

                              Navigator.pop(context);
                            },
                          ),
                          ElevatedButton(
                            child: isLivestreamOn
                                ? const Text('Stop Livestream')
                                : const Text('Start Livestream'),
                            onPressed: () {
                              if (isLivestreamOn)
                                widget.meeting.stopLivestream();
                              else
                                widget.meeting.startLivestream(
                                  [
                                    {
                                      'url': "url1",
                                      'streamKey': "streamKey1",
                                    },
                                    {
                                      'url': "url2",
                                      'streamKey': "streamKey2",
                                    }
                                  ],
                                );

                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.more_vert),
          ),
        ),
      ],
    );
  }
}
