import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/utils/spacer.dart';
import 'package:videosdk_flutter_example/widgets/one_to_one_participant_view/participant_view.dart';

class ParticipantViewOneToOne extends StatefulWidget {
  final Room meeting;
  const ParticipantViewOneToOne({Key? key, required this.meeting})
      : super(key: key);

  @override
  State<ParticipantViewOneToOne> createState() =>
      _ParticipantViewOneToOneState();
}

class _ParticipantViewOneToOneState extends State<ParticipantViewOneToOne> {
  Stream? localVideoStream;
  Stream? localShareStream;
  Stream? localAudioStream;
  Stream? remoteAudioStream;
  Stream? remoteVideoStream;
  Stream? remoteShareStream;

  Stream? largeViewStream;
  Stream? smallViewStream;
  Participant? largeParticipant, smallParticipant;
  Participant? localParticipant, remoteParticipant;
  String? activeSpeakerId, presenterId;

  @override
  void initState() {
    localParticipant = widget.meeting.localParticipant;
    // Setting meeting event listeners
    setMeetingListeners(widget.meeting);

    try {
      remoteParticipant = widget.meeting.participants.entries.first.value;
      if (remoteParticipant != null) {
        addParticipantListener(remoteParticipant!, true);
      }
    } catch (error) {}
    addParticipantListener(localParticipant!, false);
    super.initState();
    updateView();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: IntrinsicHeight(
        child: Stack(children: [
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: black800,
              ),
              child: Stack(
                children: [
                  largeViewStream != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: RTCVideoView(
                            largeViewStream?.renderer as RTCVideoRenderer,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                          ),
                        )
                      : Center(
                          child: localShareStream == null
                              ? Container(
                                  padding: const EdgeInsets.all(30),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: black700,
                                  ),
                                  child: Text(
                                    remoteParticipant != null
                                        ? remoteParticipant!
                                            .displayName.characters.first
                                            .toUpperCase()
                                        : localParticipant!
                                            .displayName.characters.first
                                            .toUpperCase(),
                                    style: const TextStyle(fontSize: 50),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                                widget.meeting
                                                    .disableScreenShare()
                                              })
                                    ]),
                        ),
                  if (remoteAudioStream == null &&
                      remoteShareStream == null &&
                      localShareStream == null)
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
          if (remoteShareStream != null)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: black700,
                ),
                child: Text(remoteShareStream != null
                    ? "${remoteParticipant?.displayName} is presenting"
                    : "${remoteParticipant?.displayName}"),
              ),
            ),
          // if (largeParticipant != null)
          //   ParticipantView(
          //     participant: largeParticipant!,
          //     showShare: true,
          //   ),
          if (remoteParticipant != null || localShareStream != null)
            Positioned(
              right: 8,
              bottom: 8,
              // child: Container(
              //   height: 160,
              //   width: 100,
              //   child: ParticipantView(
              //       participant: smallParticipant!, showShare: false),
              // )
              child: Container(
                  height: 160,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: black600,
                  ),
                  child: Stack(
                    children: [
                      smallViewStream != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: RTCVideoView(
                                smallViewStream?.renderer as RTCVideoRenderer,
                                objectFit: RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                              ),
                            )
                          : Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: black500,
                                ),
                                child: Text(
                                  remoteShareStream != null
                                      ? remoteParticipant!
                                          .displayName.characters.first
                                          .toUpperCase()
                                      : localParticipant!
                                          .displayName.characters.first
                                          .toUpperCase(),
                                  style: TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                      if ((localAudioStream == null &&
                              remoteShareStream == null) ||
                          (remoteAudioStream == null &&
                              remoteShareStream != null))
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
            ),
        ]),
      ),
    );
  }

  void setMeetingListeners(Room _meeting) {
    // Called when participant joined meeting
    _meeting.on(
      Events.participantJoined,
      (Participant participant) {
        setState(() {
          remoteParticipant = widget.meeting.participants.entries.first.value;
          if (remoteParticipant != null) {
            addParticipantListener(remoteParticipant!, true);
          }
        });
      },
    );

    // Called when participant left meeting
    _meeting.on(
      Events.participantLeft,
      (participantId) {
        if (remoteParticipant?.id == participantId) {
          setState(() {
            remoteParticipant = null;
            remoteShareStream = null;
            remoteVideoStream = null;
            updateView();
          });
        }
      },
    );

    _meeting.on(Events.presenterChanged, (_presenterId) {
      log("Presenter Changed " + _presenterId.toString());
      setState(() {
        presenterId = _presenterId;
        updateView();
      });
    });

    // Called when speaker is changed
    _meeting.on(Events.speakerChanged, (_activeSpeakerId) {
      setState(() {
        activeSpeakerId = _activeSpeakerId;
      });
    });
  }

  void updateView() {
    Stream? _largeViewStream, _smallViewStream;
    Participant? _largeViewParticipant, _smallViewParticipant;
    // log("Presenter Id::" + presenterId.toString());
    // if (presenterId != null) {
    //   if (presenterId == localParticipant!.id) {
    //     if (remoteParticipant != null) {
    //       _smallViewParticipant = remoteParticipant;
    //     } else {
    //       _smallViewParticipant = localParticipant;
    //     }
    //     _largeViewParticipant = localParticipant;
    //   } else {
    //     _largeViewParticipant = remoteParticipant;
    //     _smallViewParticipant = remoteParticipant;
    //   }
    // } else {
    //   if (remoteParticipant != null) {
    //     _largeViewParticipant = remoteParticipant;
    //     _smallViewParticipant = localParticipant;
    //   } else {
    //     _largeViewParticipant = localParticipant;
    //     _smallViewParticipant = null;
    //   }
    // }
    if (remoteParticipant != null) {
      if (remoteShareStream != null) {
        _largeViewStream = remoteShareStream;
      } else if (localShareStream != null) {
        _largeViewStream = null;
      } else if (remoteVideoStream != null) {
        _largeViewStream = remoteVideoStream;
      }
      if (remoteShareStream != null || localShareStream != null) {
        if (remoteVideoStream != null) {
          _smallViewStream = remoteVideoStream;
        }
      } else {
        _smallViewStream = localVideoStream;
      }
    } else {
      if (localShareStream != null) {
        _smallViewStream = localVideoStream;
      } else {
        _largeViewStream = localVideoStream;
      }
    }

    // setState(() {
    //   largeParticipant = _largeViewParticipant;
    //   smallParticipant = _smallViewParticipant;
    // });
    setState(() {
      largeViewStream = _largeViewStream;
      smallViewStream = _smallViewStream;
    });
  }

  void addParticipantListener(Participant participant, bool isRemote) {
    participant.streams.forEach((key, Stream stream) {
      setState(() {
        if (stream.kind == 'video') {
          if (isRemote) {
            remoteVideoStream = stream;
          } else {
            localVideoStream = stream;
          }
        } else if (stream.kind == 'share') {
          if (isRemote) {
            remoteShareStream = stream;
          } else {
            localShareStream = stream;
          }
        } else if (stream.kind == 'audio') {
          if (isRemote) {
            remoteAudioStream = stream;
          } else {
            localAudioStream = stream;
          }
        }
        updateView();
      });
    });
    participant.on(Events.streamEnabled, (Stream _stream) {
      setState(() {
        if (_stream.kind == "video") {
          if (isRemote) {
            remoteVideoStream = _stream;
          } else {
            localVideoStream = _stream;
          }
        } else if (_stream.kind == "share") {
          if (isRemote) {
            remoteShareStream = _stream;
          } else {
            localShareStream = _stream;
          }
          // presenterId = participant.id;
          // updateView();
        } else if (_stream.kind == 'audio') {
          if (isRemote) {
            remoteAudioStream = _stream;
          } else {
            localAudioStream = _stream;
          }
        }
        updateView();
      });
    });

    participant.on(Events.streamDisabled, (Stream _stream) {
      setState(() {
        if (_stream.kind == "video") {
          if (isRemote) {
            remoteVideoStream = null;
          } else {
            localVideoStream = null;
          }
        } else if (_stream.kind == "share") {
          if (isRemote) {
            remoteShareStream = null;
          } else {
            localShareStream = null;
          }
          // presenterId = null;
          // updateView();
        } else if (_stream.kind == 'audio') {
          if (isRemote) {
            remoteAudioStream = null;
          } else {
            localAudioStream = null;
          }
        }
        updateView();
      });
    });
  }
}
