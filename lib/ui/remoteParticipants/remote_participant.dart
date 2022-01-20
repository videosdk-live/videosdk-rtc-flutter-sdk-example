import 'package:flutter/material.dart';
import 'package:videosdk/rtc.dart';

import '../utils/toast.dart';

class RemoteParticipant extends StatefulWidget {
  final Participant participant;

  const RemoteParticipant({Key? key, required this.participant})
      : super(key: key);

  @override
  RemoteParticipantState createState() => RemoteParticipantState();
}

class RemoteParticipantState extends State<RemoteParticipant> {
  late final Participant participant;

  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;
  String? quality;

  @override
  initState() {
    _initStreamListeners();

    super.initState();

    widget.participant.streams.forEach((key, Stream stream) {
      setState(() {
        if (stream.kind == 'video') {
          videoStream = stream;
        } else if (stream.kind == 'audio') {
          audioStream = stream;
        } else if (stream.kind == 'share') {
          shareStream = stream;
        }
      });
    });
  }

  _initStreamListeners() {
    widget.participant.on("stream-enabled", (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video') {
          videoStream = _stream;
        } else if (_stream.kind == 'audio') {
          audioStream = _stream;
        } else if (_stream.kind == 'share') {
          shareStream = _stream;
        }
      });
    });

    widget.participant.on("stream-disabled", (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
          videoStream = null;
        } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
          audioStream = null;
        } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
          shareStream = null;
        }
      });
    });

    widget.participant.on("stream-paused", (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
          videoStream = _stream;
        } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
          audioStream = _stream;
        } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
          shareStream = _stream;
        }
      });
    });

    widget.participant.on("stream-resumed", (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
          videoStream = _stream;
        } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
          audioStream = _stream;
        } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
          shareStream = _stream;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      color: const Color.fromARGB(180, 0, 0, 0),
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
                        : const Center(
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
                    color: const Color.fromARGB(100, 0, 0, 0),
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      children: [
                        Text(
                          widget.participant.displayName,
                          style: const TextStyle(
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
                                  toastMsg("Webcam requested");
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
                                    ? const Icon(Icons.play_arrow)
                                    : const Icon(Icons.pause),
                              )
                            else
                              const IconButton(
                                onPressed: null,
                                icon: Icon(Icons.play_arrow),
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
                                  toastMsg("Mic requested");
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
                                onPressed: audioStream!.track.paused
                                    ? audioStream!.resume
                                    : audioStream!.pause,
                                icon: audioStream!.track.paused
                                    ? const Icon(Icons.play_arrow)
                                    : const Icon(Icons.pause),
                              )
                            else
                              const IconButton(
                                onPressed: null,
                                icon: Icon(Icons.play_arrow),
                              ),
                          ],
                        ),
                        Text(
                          "Screen share is ${shareStream != null ? "on" : "off"}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        if (videoStream != null)
                          Row(
                            children: [
                              const Text("Quality: "),
                              ElevatedButton(
                                // style: ButtonStyle(size/),
                                onPressed: () {
                                  String newQuality = quality != null
                                      ? quality == "low"
                                          ? "med"
                                          : quality == "med"
                                              ? "high"
                                              : "low"
                                      : "med";

                                  widget.participant.setQuality(newQuality);
                                  setState(() {
                                    quality = newQuality;
                                  });
                                },
                                child: Text(
                                  quality != null
                                      ? quality!.toUpperCase()
                                      : "Low",
                                ),
                              ),
                            ],
                          ),
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
