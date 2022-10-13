import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/utils/spacer.dart';
import 'package:videosdk_flutter_example/widgets/one_to_one_participant_view/local_screen_share_view.dart';
import 'package:videosdk_flutter_example/widgets/one_to_one_participant_view/participant_view.dart';
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
      remoteParticipant = widget.meeting.participants.isNotEmpty
          ? widget.meeting.participants.entries.first.value
          : null;
      if (remoteParticipant != null) {
        addParticipantListener(remoteParticipant!, true);
      }
    } catch (error) {}
    addParticipantListener(localParticipant!, false);
    super.initState();
    updateView();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: IntrinsicHeight(
        child: Stack(children: [
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: black800,
              ),
              child: ParticipantView(
                avatarBackground: black700,
                stream: largeViewStream,
                isMicOn: remoteParticipant != null
                    ? remoteAudioStream != null
                    : localAudioStream != null,
                onStopScreeenSharePressed: () =>
                    widget.meeting.disableScreenShare(),
                participantName: remoteParticipant != null
                    ? remoteParticipant!.displayName
                    : localParticipant!.displayName,
                isLocalScreenShare: localShareStream != null,
                isScreenShare:
                    remoteShareStream != null || localShareStream != null,
              )),
          if (remoteParticipant != null || localShareStream != null)
            Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                    height: 160,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: black600,
                    ),
                    child: ParticipantView(
                      avatarTextSize: 30,
                      avatarBackground: black500,
                      stream: smallViewStream,
                      isMicOn: (localAudioStream != null &&
                              remoteShareStream == null) ||
                          (remoteAudioStream != null &&
                              remoteShareStream != null),
                      onStopScreeenSharePressed: () =>
                          widget.meeting.disableScreenShare(),
                      participantName: remoteShareStream != null
                          ? remoteParticipant!.displayName
                          : localParticipant!.displayName,
                      isLocalScreenShare: false,
                      isScreenShare: false,
                    ))),
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
          remoteParticipant = widget.meeting.participants.isNotEmpty
              ? widget.meeting.participants.entries.first.value
              : null;
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
        setState(() {
          remoteParticipant = widget.meeting.participants.isNotEmpty
              ? widget.meeting.participants.entries.first.value
              : null;
          if (remoteParticipant != null) {
            addParticipantListener(remoteParticipant!, true);
            updateView();
          }
        });
      },
    );

    _meeting.on(Events.presenterChanged, (_presenterId) {
      setState(() {
        presenterId = _presenterId;
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
