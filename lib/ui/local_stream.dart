import 'package:flutter/material.dart';
import 'package:videosdk/meeting.dart';
import 'package:videosdk/participant.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:videosdk/stream.dart';

class LocalStream extends StatefulWidget {
  final Participant localParticipant;
  final Meeting meeting;

  LocalStream({
    Key? key,
    required this.localParticipant,
    required this.meeting,
  }) : super(key: key);

  @override
  LocalStreamState createState() => LocalStreamState();
}

class LocalStreamState extends State<LocalStream> {
  Stream? videoStream;
  Stream? audioStream;

  @override
  initState() {
    _initStreamListners();

    super.initState();
  }

  _initStreamListners() {
    widget.localParticipant.on(
      "stream-enabled",
      (Stream _stream) {
        setState(
          () {
            if (_stream.kind == 'video') {
              videoStream = _stream;
            } else if (_stream.kind == 'audio') {
              audioStream = _stream;
            }
          },
        );
      },
    );

    widget.localParticipant.on(
      "stream-disabled",
      (Stream _stream) {
        if (_stream.kind == 'video') {
          if (videoStream?.id == _stream.id) {
            setState(
              () {
                videoStream = null;
              },
            );
          }
        } else if (_stream.kind == 'audio') {
          if (audioStream?.id == _stream.id) {
            setState(
              () {
                audioStream = null;
              },
            );
          }
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Column(
            children: [
              Text(
                'Name: ${widget.localParticipant.displayName}',
                overflow: TextOverflow.fade,
              ),
              Text(
                'Video On: ${videoStream != null ? "Yes" : "No"}',
                overflow: TextOverflow.fade,
              ),
              Text(
                'Audio On: ${audioStream != null ? "Yes" : "No"}',
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
        Container(
          height: 240.0,
          width: 240.0,
          child: videoStream?.renderer != null && videoStream?.track != null
              ? RTCVideoView(
                  videoStream?.renderer as RTCVideoRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              : FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(Icons.person),
                ),
        ),
        Wrap(
          children: [
            ElevatedButton(
              onPressed: widget.meeting.disableWebcam,
              child: Text("disableWebcam"),
            ),
            ElevatedButton(
              onPressed: widget.meeting.enableWebcam,
              child: Text("enableWebcam"),
            ),
            ElevatedButton(
              onPressed: widget.meeting.disableMic,
              child: Text("disableMic"),
            ),
            ElevatedButton(
              onPressed: widget.meeting.enableMic,
              child: Text("enableMic"),
            ),
            ElevatedButton(
              onPressed: widget.meeting.join,
              child: Text("join"),
            ),
            ElevatedButton(
              onPressed: widget.meeting.leave,
              child: Text("leave"),
            ),
          ],
        ),
      ],
    );
  }
}
