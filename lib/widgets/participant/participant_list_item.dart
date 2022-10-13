import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';

class ParticipantListItem extends StatefulWidget {
  final Participant participant;
  const ParticipantListItem({Key? key, required this.participant})
      : super(key: key);

  @override
  State<ParticipantListItem> createState() => _ParticipantListItemState();
}

class _ParticipantListItemState extends State<ParticipantListItem> {
  Stream? videoStream;
  Stream? audioStream;

  @override
  void initState() {
    widget.participant.streams.forEach((key, Stream stream) {
      if (stream.kind == "video") {
        videoStream = stream;
      } else if (stream.kind == 'audio') {
        audioStream = stream;
      }
      log("Stream: " + stream.kind.toString());
    });

    super.initState();
    addParticipantListener(widget.participant);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: black600, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: black500,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: black500),
            ),
            child: const Icon(Icons.person),
          ),
          Expanded(
              child: Text(
            widget.participant.isLocal ? "You" : widget.participant.displayName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          )),
          Container(
            margin: EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: audioStream != null ? black600 : red,
              border: Border.all(color: audioStream != null ? black500 : red),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(audioStream != null ? Icons.mic : Icons.mic_off),
          ),
          Container(
            margin: EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: videoStream != null ? black600 : red,
              border: Border.all(color: videoStream != null ? black500 : red),
              borderRadius: BorderRadius.circular(30),
            ),
            child:
                Icon(videoStream != null ? Icons.videocam : Icons.videocam_off),
          ),
        ],
      ),
    );
  }

  void addParticipantListener(Participant participant) {
    participant.on(Events.streamEnabled, (Stream _stream) {
      if (mounted) {
        setState(() {
          if (_stream.kind == "video") {
            videoStream = _stream;
          } else if (_stream.kind == 'audio') {
            audioStream = _stream;
          }
        });
      }
    });

    participant.on(Events.streamDisabled, (Stream _stream) {
      if (mounted) {
        setState(() {
          if (_stream.kind == "video") {
            videoStream = null;
          } else if (_stream.kind == 'audio') {
            audioStream = null;
          }
        });
      }
    });
  }
}
