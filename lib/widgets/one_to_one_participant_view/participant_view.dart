import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/utils/spacer.dart';

class ParticipantView extends StatefulWidget {
  Participant participant;
  bool showShare;
  ParticipantView(
      {Key? key, required this.participant, required this.showShare})
      : super(key: key);

  @override
  State<ParticipantView> createState() => _ParticipantViewState();
}

class _ParticipantViewState extends State<ParticipantView> {
  Stream? videoStream;
  Stream? shareStream;
  Stream? audioStream;

  // Stream? largeViewStream;
  // Stream? smallViewStream;
  // Participant? localParticipant, remoteParticipant;
  // String? activeSpeakerId;

  @override
  void initState() {
    addParticipantListener(widget.participant);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    // addParticipantListener(widget.participant);
    log("Dependency Changed");
  }

  @override
  void didUpdateWidget(covariant ParticipantView oldWidget) {
    // TODO: implement didUpdateWidget
    // if (oldWidget.participant.id != widget.participant.id) {
    //   addParticipantListener(widget.participant);
    // }
    log("DidUpdateWidget old::" +
        oldWidget.participant.id +
        "::" +
        widget.participant.id);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: black800,
            ),
            child: Stack(
              children: [
                shareStream != null && widget.showShare
                    ? widget.participant.isLocal
                        ? Column(mainAxisAlignment: MainAxisAlignment.center,
                            // crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                SvgPicture.asset(
                                  "assets/ic_screen_share.svg",
                                  height: 40,
                                ),
                                const VerticalSpacer(20),
                                const Text(
                                  "You are presenting to everyone",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                const VerticalSpacer(20),
                                MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 30),
                                    color: purple,
                                    child: const Text("Stop Presenting",
                                        style: TextStyle(fontSize: 16)),
                                    onPressed: () => {
                                          // widget.meeting
                                          //     .disableScreenShare()
                                        })
                              ])
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: RTCVideoView(
                              shareStream?.renderer as RTCVideoRenderer,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ),
                          )
                    : videoStream != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: RTCVideoView(
                              videoStream?.renderer as RTCVideoRenderer,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ),
                          )
                        : Center(
                            child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: black700,
                            ),
                            child: Text(
                              widget.participant.displayName.characters.first
                                  .toUpperCase(),
                              style: const TextStyle(fontSize: 50),
                            ),
                          )),
                if (audioStream == null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: black700,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.mic_off,
                          size: 14,
                        )),
                  ),
              ],
            )),
        if (shareStream != null && widget.showShare)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: black700,
              ),
              child: Text(shareStream != null
                  ? "${widget.participant.displayName} is presenting"
                  : "${widget.participant.displayName}"),
            ),
          ),
      ],
    );
  }

  void addParticipantListener(Participant participant) {
    setState(() {
      audioStream = null;
      videoStream = null;
      shareStream = null;
    });
    participant.streams.forEach((key, Stream stream) {
      setState(() {
        if (stream.kind == 'video') {
          videoStream = stream;
        } else if (stream.kind == 'share') {
          shareStream = stream;
        } else if (stream.kind == 'audio') {
          audioStream = stream;
        }
        // updateView();
      });
    });
    participant.on(Events.streamEnabled, (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video') {
          videoStream = _stream;
        } else if (_stream.kind == 'share') {
          shareStream = _stream;
        } else if (_stream.kind == 'audio') {
          audioStream = _stream;
        }
        // updateView();
      });
    });

    participant.on(Events.streamDisabled, (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video') {
          videoStream = null;
        } else if (_stream.kind == 'share') {
          shareStream = null;
        } else if (_stream.kind == 'audio') {
          audioStream = null;
        }
        // updateView();
      });
    });
  }
}
