import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:videosdk/meeting.dart';
import 'package:videosdk/meeting_builder.dart';
import 'package:videosdk/participant.dart';

import '../widgets/localParticipant/local_participant.dart';
import '../widgets/meeting_controls/meeting_actions.dart';
import '../widgets/remoteParticipants/list_remote_participants.dart';
import 'startup_screen.dart';

class MeetingScreen extends StatefulWidget {
  final String meetingId, token, displayName;
  final bool micEnabled, webcamEnabled;
  const MeetingScreen({
    Key? key,
    required this.meetingId,
    required this.token,
    required this.displayName,
    this.micEnabled = true,
    this.webcamEnabled = true,
  }) : super(key: key);

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  Map<String, Participant> participants = {};
  Participant? localParticipant;
  Meeting? meeting;

  String? activeSpeakerId;
  String? activePresenterId;

  _handleMeetingListeners(Meeting meeting) {
    meeting.on(
      "participant-joined",
      (Participant participant) {
        final newParticipants = participants;
        newParticipants[participant.id] = participant;
        setState(() {
          participants = newParticipants;
        });
      },
    );
    //
    meeting.on(
      "participant-left",
      (participantId) {
        final newParticipants = participants;

        newParticipants.remove(participantId);
        setState(() {
          participants = newParticipants;
        });
      },
    );
    //
    meeting.on('meeting-left', () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StartupScreen()),
          (route) => false);
    });

    meeting.on('speaker-changed', (_activeSpeakerId) {
      setState(() {
        activeSpeakerId = _activeSpeakerId;
      });
      log("meeting speaker-changed => $_activeSpeakerId");
    });
    //
    meeting.on('presenter-changed', (_activePresenterId) {
      setState(() {
        activePresenterId = _activePresenterId;
      });
      log("meeting presenter-changed => $_activePresenterId");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MeetingBuilder(
      meetingId: widget.meetingId,
      displayName: widget.displayName,
      token: widget.token,
      micEnabled: widget.micEnabled,
      webcamEnabled: widget.webcamEnabled,
      builder: (_meeting) {
        _meeting.on(
          "meeting-joined",
          () {
            setState(() {
              localParticipant = _meeting.localParticipant;
              meeting = _meeting;
            });
            _handleMeetingListeners(_meeting);
          },
        );

        if (meeting == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("waiting to join meeting"),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          floatingActionButton: MeetingActions(
            localParticipant: localParticipant as Participant,
            meeting: meeting as Meeting,
            meetingId: widget.meetingId,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          appBar: AppBar(title: const Text('VideoSDK RTC')),
          body: Stack(
            children: [
              Column(
                children: [
                  // Text("Active Speaker Id: $activeSpeakerId"),
                  // Text("Active Presenter Id: $activePresenterId"),
                  if (participants.isNotEmpty)
                    Expanded(
                      child: ListRemoteParticipants(
                        participants: participants,
                      ),
                    )
                  else
                    const Expanded(
                      child: Center(
                        child: Text("No participants."),
                      ),
                    ),
                ],
              ),
              LocalParticipant(
                localParticipant: localParticipant as Participant,
                meeting: meeting as Meeting,
              )
            ],
          ),
        );
      },
    );
  }
}
