import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/widgets/conference-call/participant_grid_tile.dart';

class ConferenceParticipantGrid extends StatefulWidget {
  final Room meeting;
  const ConferenceParticipantGrid({Key? key, required this.meeting})
      : super(key: key);

  @override
  State<ConferenceParticipantGrid> createState() =>
      _ConferenceParticipantGridState();
}

class _ConferenceParticipantGridState extends State<ConferenceParticipantGrid> {
  late Participant localParticipant;
  String? activeSpeakerId;
  String? presenterId;
  int numberofColumns = 1;
  int numberOfMaxOnScreenParticipants = 6;
  String quality = "high";

  Map<String, Participant> participants = {};
  Map<String, Participant> onScreenParticipants = {};

  @override
  void initState() {
    localParticipant = widget.meeting.localParticipant;
    participants.putIfAbsent(localParticipant.id, () => localParticipant);
    participants.addAll(widget.meeting.participants);
    presenterId = widget.meeting.activePresenterId;
    updateOnScreenParticipants();
    // Setting meeting event listeners
    setMeetingListeners(widget.meeting);

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0;
            i < (onScreenParticipants.length / numberofColumns).ceil();
            i++)
          Flexible(
              child: Row(
            children: [
              for (int j = 0;
                  j <
                      onScreenParticipants.values
                          .toList()
                          .sublist(
                              i * numberofColumns,
                              (i + 1) * numberofColumns >
                                      onScreenParticipants.length
                                  ? onScreenParticipants.length
                                  : (i + 1) * numberofColumns)
                          .length;
                  j++)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ParticipantGridTile(
                        key: Key(onScreenParticipants.values
                            .toList()
                            .sublist(
                                i * numberofColumns,
                                (i + 1) * numberofColumns >
                                        onScreenParticipants.length
                                    ? onScreenParticipants.length
                                    : (i + 1) * numberofColumns)
                            .elementAt(j)
                            .id),
                        participant: onScreenParticipants.values
                            .toList()
                            .sublist(
                                i * numberofColumns,
                                (i + 1) * numberofColumns >
                                        onScreenParticipants.length
                                    ? onScreenParticipants.length
                                    : (i + 1) * numberofColumns)
                            .elementAt(j),
                        activeSpeakerId: activeSpeakerId,
                        quality: quality),
                  ),
                )
            ],
          ))
      ],
    );
  }

  void setMeetingListeners(Room _meeting) {
    // Called when participant joined meeting
    _meeting.on(
      Events.participantJoined,
      (Participant participant) {
        // addParticipantListener(participant);
        final newParticipants = participants;
        newParticipants[participant.id] = participant;
        setState(() {
          participants = newParticipants;
          updateOnScreenParticipants();
        });
      },
    );

    // Called when participant left meeting
    _meeting.on(
      Events.participantLeft,
      (participantId) {
        final newParticipants = participants;

        newParticipants.remove(participantId);
        setState(() {
          participants = newParticipants;
          updateOnScreenParticipants();
        });
      },
    );

    _meeting.on(
      Events.speakerChanged,
      (_activeSpeakerId) {
        setState(() {
          activeSpeakerId = _activeSpeakerId;
          updateOnScreenParticipants();
        });
      },
    );

    _meeting.on(Events.presenterChanged, (_presenterId) {
      setState(() {
        presenterId = _presenterId;
        numberOfMaxOnScreenParticipants = _presenterId != null ? 2 : 6;
        updateOnScreenParticipants();
      });
    });

    // Called when speaker is changed
    _meeting.on(Events.speakerChanged, (_activeSpeakerId) {
      setState(() {
        activeSpeakerId = _activeSpeakerId;
      });
    });

    _meeting.localParticipant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == "share") {
        setState(() {
          numberOfMaxOnScreenParticipants = 2;
          updateOnScreenParticipants();
        });
      }
    });
    _meeting.localParticipant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == "share") {
        setState(() {
          numberOfMaxOnScreenParticipants = 6;
          updateOnScreenParticipants();
        });
      }
    });
  }

  addParticipantListener(Participant participant) {
    participant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == "video") {
        if (!stream.track.paused) {
          stream.track.pause();
        }
      }
    });
  }

  updateOnScreenParticipants() {
    Map<String, Participant> newScreenParticipants = <String, Participant>{};
    participants.values
        .toList()
        .sublist(
            0,
            participants.length > numberOfMaxOnScreenParticipants
                ? numberOfMaxOnScreenParticipants
                : participants.length)
        .forEach((participant) {
      newScreenParticipants.putIfAbsent(participant.id, () => participant);
    });
    if (!newScreenParticipants.containsKey(activeSpeakerId) &&
        activeSpeakerId != null) {
      newScreenParticipants.remove(newScreenParticipants.keys.last);
      newScreenParticipants.putIfAbsent(
          activeSpeakerId!,
          () => participants.values
              .firstWhere((element) => element.id == activeSpeakerId));
    }
    if (!listEquals(newScreenParticipants.keys.toList(),
        onScreenParticipants.keys.toList())) {
      setState(() {
        onScreenParticipants = newScreenParticipants;
        quality = newScreenParticipants.length > 4
            ? "low"
            : newScreenParticipants.length > 2
                ? "medium"
                : "high";
      });
    }
    if (numberofColumns !=
        (newScreenParticipants.length > 2 ||
                numberOfMaxOnScreenParticipants == 2
            ? 2
            : 1)) {
      setState(() {
        numberofColumns = newScreenParticipants.length > 2 ||
                numberOfMaxOnScreenParticipants == 2
            ? 2
            : 1;
      });
    }
    // pauseInvisibleParticipants();
  }

  pauseInvisibleParticipants() {
    participants.forEach((key, value) {
      if (!onScreenParticipants.containsKey(key)) {
        value.streams.forEach((key, value) {
          if (value.kind == "video") {
            value.track.pause();
          }
        });
      } else {
        value.streams.forEach((key, value) {
          if (value.kind == "video") {
            value.track.resume();
          }
        });
      }
    });
  }
}
