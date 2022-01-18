import 'remote_participant.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/participant.dart';

class ListRemoteParticipants extends StatelessWidget {
  final Map<String, Participant> participants;

  const ListRemoteParticipants({
    Key? key,
    required this.participants,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      padding: const EdgeInsets.all(4.0),
      children: <Widget>[
        for (dynamic perticipant in participants.values)
          RemoteParticipant(
            key: ValueKey(perticipant.id),
            participant: participants[perticipant.id]!,
          ),
      ],
    );
  }
}
