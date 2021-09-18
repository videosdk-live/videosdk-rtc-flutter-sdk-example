import 'remote_stream.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/participant.dart';

class ListRemoteStreams extends StatelessWidget {
  final Map<String, Participant> participants;

  const ListRemoteStreams({
    Key? key,
    required this.participants,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (dynamic peer in participants.values)
          Container(
            key: ValueKey('${peer.id}_container'),
            width: 240.0,
            height: 240.0,
            child: RemoteStream(
              key: ValueKey(peer.id),
              participant: participants[peer.id]!,
            ),
          ),
      ],
    );
  }
}
