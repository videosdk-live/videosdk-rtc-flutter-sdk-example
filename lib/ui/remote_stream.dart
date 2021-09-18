import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:videosdk/participant.dart';
import 'package:videosdk/stream.dart';

class RemoteStream extends StatefulWidget {
  final Participant participant;

  RemoteStream({Key? key, required this.participant}) : super(key: key);

  @override
  RemoteStreamState createState() => RemoteStreamState();
}

class RemoteStreamState extends State<RemoteStream> {
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
          videoStream = _stream;
        } else if (_stream.kind == 'audio') {
          audioStream = _stream;
        }
      });
    });

    widget.participant.on("stream-disabled", (Stream _stream) {
      if (_stream.kind == 'video') {
        if (videoStream?.id == _stream.id) {
          setState(() {
            videoStream = null;
          });
        }
      } else if (_stream.kind == 'audio') {
        if (audioStream?.id == _stream.id) {
          setState(() {
            audioStream = null;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240.0,
      width: 240.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (videoStream?.renderer != null && videoStream?.track != null)
            RTCVideoView(
              videoStream?.renderer as RTCVideoRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
          else
            Container(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(
                  Icons.person,
                  // size: double.infinity,
                ),
              ),
            ),
          Positioned(
            bottom: 5,
            left: 2,
            child: Container(
              margin: const EdgeInsets.only(left: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Name: ${widget.participant.displayName}',
                    overflow: TextOverflow.fade,
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Video On: ${videoStream != null ? "Yes" : "No"}',
                    overflow: TextOverflow.fade,
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Audio On: ${audioStream != null ? "Yes" : "No"}',
                    overflow: TextOverflow.fade,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              padding: const EdgeInsets.all(8),
            ),
          ),
          Positioned(
            top: 5,
            left: 5,
            child: ElevatedButton(
              onPressed: () {
                // widget.participant.pauseVideo();
              },
              child: Text("Pause Video"),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: ElevatedButton(
              onPressed: () {
                // widget.participant.resumeVideo();
              },
              child: Text("Resume Video"),
            ),
          ),
          Positioned(
            top: 40,
            left: 5,
            child: ElevatedButton(
              onPressed: () {
                // widget.participant.pauseAudio();
              },
              child: Text("Pause Audio"),
            ),
          ),
          Positioned(
            top: 40,
            right: 5,
            child: ElevatedButton(
              onPressed: () {
                // widget.participant.resumeAudio();
              },
              child: Text("Resume Audio"),
            ),
          )
        ],
      ),
    );
  }
}
