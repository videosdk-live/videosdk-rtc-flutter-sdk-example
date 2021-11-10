import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:videosdk/participant.dart';
import 'package:videosdk/stream.dart';
import 'package:videosdk/rtc.dart';

class RemoteParticipant extends StatefulWidget {
  final Participant participant;

  RemoteParticipant({Key? key, required this.participant}) : super(key: key);

  @override
  RemoteParticipantState createState() => RemoteParticipantState();
}

class RemoteParticipantState extends State<RemoteParticipant> {
  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;

  @override
  initState() {
    _initStreamListners();

    super.initState();
  }

  _initStreamListners() {
    widget.participant.on("stream-enabled", (Stream _stream) {
      setState(() {
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
      });
    });

    widget.participant.on("stream-disabled", (Stream _stream) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      color: Color.fromARGB(255, 84, 110, 122),
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: (videoStream != null)
                        ? RTCVideoView(
                            videoStream?.renderer as RTCVideoRenderer,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                          )
                        : Center(
                            child: Icon(
                              Icons.person,
                              size: 180.0,
                              color: Color.fromARGB(255, 176, 190, 197),
                            ),
                          ),
                  ),
                  if (shareStream != null)
                    Expanded(
                      child: RTCVideoView(
                        shareStream?.renderer as RTCVideoRenderer,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    )
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: FittedBox(
                  child: Container(
                    color: Color.fromARGB(100, 0, 0, 0),
                    padding: EdgeInsets.all(6.0),
                    child: Column(
                      children: [
                        Text(
                          "Name: ${widget.participant.displayName}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Webcam On: ${videoStream != null ? "Yes" : "No"}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Mic On: ${audioStream != null ? "Yes" : "No"}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Screen Share On: ${shareStream != null ? "Yes" : "No"}",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
