import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/widgets/participant/participant_list_item.dart';

class ParticipantList extends StatefulWidget {
  final Room meeting;
  const ParticipantList({Key? key, required this.meeting}) : super(key: key);

  @override
  State<ParticipantList> createState() => _ParticipantListState();
}

class _ParticipantListState extends State<ParticipantList> {
  Map<String, Participant> _participants = {};

  @override
  void initState() {
    _participants.putIfAbsent(widget.meeting.localParticipant.id,
        () => widget.meeting.localParticipant);
    _participants.addAll(widget.meeting.participants);
    addMeetingListeners(widget.meeting);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: Text("Participants (" +
            (widget.meeting.participants.length + 1).toString() +
            ")"),
        automaticallyImplyLeading: false,
        backgroundColor: secondaryColor,
        elevation: 0,
        actions: [
          // Close Button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: _participants == null
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _participants.values.length,
                        itemBuilder: (context, index) => ParticipantListItem(
                            participant: _participants.values.elementAt(index)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addMeetingListeners(Room meeting) {
    meeting.on(Events.participantJoined, (participant) {
      if (mounted) {
        final newParticipants = _participants;
        newParticipants[participant.id] = participant;
        setState(() => _participants = newParticipants);
      }
    });

    meeting.on(Events.participantLeft, (participantId) {
      if (mounted) {
        final newParticipants = _participants;
        newParticipants.remove(participantId);

        setState(() => _participants = newParticipants);
      }
    });
  }
}
