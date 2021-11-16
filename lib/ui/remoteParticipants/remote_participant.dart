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

    widget.participant.streams.forEach((key, Stream stream) {
      if (stream.kind == 'video') {
        setState(() {
          videoStream = stream;
        });
      } else if (stream.kind == 'audio') {
        setState(() {
          audioStream = stream;
        });
      } else if (stream.kind == 'share') {
        setState(() {
          shareStream = stream;
        });
      }
    });
  }

  _initStreamListners() {
    widget.participant.on("stream-enabled", (Stream _stream) {
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

    widget.participant.on("stream-disabled", (Stream _stream) {
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

    // widget.participant.on("stream-paused", (Stream _stream) {
    //   if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
    //     setState(() {
    //       videoStream = _stream;
    //     });
    //   } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
    //     setState(() {
    //       audioStream = _stream;
    //     });
    //   } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
    //     setState(() {
    //       shareStream = _stream;
    //     });
    //   }
    // });

    // widget.participant.on("stream-resumed", (Stream _stream) {
    //   if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
    //     setState(() {
    //       videoStream = _stream;
    //     });
    //   } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
    //     setState(() {
    //       audioStream = _stream;
    //     });
    //   } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
    //     setState(() {
    //       shareStream = _stream;
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      color: Color.fromARGB(140, 0, 0, 0),
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
                              color: Color.fromARGB(140, 255, 255, 255),
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
                          "${widget.participant.displayName}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (videoStream != null) {
                                  widget.participant.disableWebcam();
                                } else {
                                  widget.participant.enableWebcam();
                                }
                              },
                              color: videoStream != null
                                  ? Colors.teal.shade600
                                  : Colors.teal.shade200,
                              icon: videoStream != null
                                  ? const Icon(Icons.videocam)
                                  : const Icon(Icons.videocam_off),
                            ),
                            if (videoStream != null)
                              IconButton(
                                onPressed: videoStream!.track.paused
                                    ? videoStream!.resume
                                    : videoStream!.pause,
                                icon: videoStream!.track.paused
                                    ? Icon(Icons.play_arrow)
                                    : Icon(Icons.pause),
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (audioStream != null) {
                                  widget.participant.disableMic();
                                } else {
                                  widget.participant.enableMic();
                                }
                              },
                              color: audioStream != null
                                  ? Colors.teal.shade600
                                  : Colors.teal.shade200,
                              icon: audioStream != null
                                  ? const Icon(Icons.mic)
                                  : const Icon(Icons.mic_off),
                            ),
                            if (audioStream != null)
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.pause),
                              ),
                            if (audioStream != null)
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.play_arrow),
                              ),
                          ],
                        ),
                        // if (videoStream != null)
                        //   Row(
                        //     children: [
                        //       Text("Set Quality : "),
                        //       ElevatedButton(
                        //         onPressed: () =>
                        //             widget.participant.setQuality("low"),
                        //         child: Text("Low"),
                        //       ),
                        //       ElevatedButton(
                        //         onPressed: () =>
                        //             widget.participant.setQuality("med"),
                        //         child: Text("Med"),
                        //       ),
                        //       ElevatedButton(
                        //         onPressed: () =>
                        //             widget.participant.setQuality("high"),
                        //         child: Text("High"),
                        //       ),
                        //     ],
                        //   ),
                        Text(
                          "Screen share is ${shareStream != null ? "on" : "off"}",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: FittedBox(
                  child: IconButton(
                    onPressed: widget.participant.remove,
                    color: Colors.red,
                    icon: const Icon(Icons.logout),
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
