import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:videosdk/rtc.dart';

import 'participant_tile.dart';

class ParticipantGridView extends StatefulWidget {
  final Meeting meeting;
  const ParticipantGridView({
    Key? key,
    required this.meeting,
  }) : super(key: key);

  @override
  State<ParticipantGridView> createState() => _ParticipantGridViewState();
}

class _ParticipantGridViewState extends State<ParticipantGridView> {
  String? activeSpeakerId;
  Participant? localParticipant;
  Map<String, Participant> participants = {};

  @override
  void initState() {
    // Initialize participants
    localParticipant = widget.meeting.localParticipant;
    participants = widget.meeting.participants;

    // Setting meeting event listeners
    setMeetingListeners(widget.meeting);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        ParticipantTile(
          participant: localParticipant!,
          isLocalParticipant: true,
        ),
        ...participants.values
            .map((participant) => ParticipantTile(participant: participant))
            .toList()
      ],
    );
  }

  void setMeetingListeners(Meeting _meeting) {
    // Called when participant joined meeting
    _meeting.on(
      "participant-joined",
      (Participant participant) {
        final newParticipants = participants;
        newParticipants[participant.id] = participant;
        setState(() {
          participants = newParticipants;
        });
      },
    );

    // Called when participant left meeting
    _meeting.on(
      "participant-left",
      (participantId) {
        final newParticipants = participants;

        newParticipants.remove(participantId);
        setState(() {
          participants = newParticipants;
        });
      },
    );

    // Called when speaker is changed
    _meeting.on('speaker-changed', (_activeSpeakerId) {
      setState(() {
        activeSpeakerId = _activeSpeakerId;
      });

      log("meeting speaker-changed => $_activeSpeakerId");
    });
  }
}
