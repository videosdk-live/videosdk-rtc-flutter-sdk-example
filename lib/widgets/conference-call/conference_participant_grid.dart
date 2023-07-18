import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/utils/toast.dart';
import 'package:videosdk_flutter_example/widgets/conference-call/manage_grid.dart';
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
  String quality = "high";

  Map<String, Participant> participants = {};
  Map<int, List<Participant>> onScreenParticipants = {};
  Map<String, int>? gridInfo;
  bool isPresenting = false;
  Map<int, List<Participant>>? activeSpeakerList;

  @override
  void initState() {
    localParticipant = widget.meeting.localParticipant;
    participants.putIfAbsent(localParticipant.id, () => localParticipant);
    participants.addAll(widget.meeting.participants);
    presenterId = widget.meeting.activePresenterId;
    isPresenting = presenterId != null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateOnScreenParticipants();
      // Setting meeting event listeners
      setMeetingListeners(widget.meeting);
    });

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
    return Flex(
      direction: ResponsiveValue<Axis>(context, conditionalValues: [
        Condition.equals(
            name: MOBILE,
            value: participants.length <= 2 ? Axis.horizontal : Axis.vertical),
        Condition.largerThan(
            name: MOBILE,
            value: isPresenting ? Axis.horizontal : Axis.vertical),
      ]).value!,
      children: [
        for (int i = 0; i < onScreenParticipants.length; i++)
          Flexible(
              child: Flex(
            direction: ResponsiveValue<Axis>(context, conditionalValues: [
              Condition.equals(
                  name: MOBILE,
                  value: participants.length <= 2
                      ? Axis.vertical
                      : Axis.horizontal),
              Condition.largerThan(
                  name: MOBILE,
                  value: isPresenting ? Axis.vertical : Axis.horizontal),
            ]).value!,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int j = 0; j < onScreenParticipants[i]!.length; j++)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ParticipantGridTile(
                      key: Key(onScreenParticipants[i]![j].id),
                      participant: onScreenParticipants[i]![j],
                      activeSpeakerId: activeSpeakerId,
                      quality: quality,
                      participantCount: participants.length,
                      isPresenting: isPresenting,
                    ),
                  ),
                )
            ],
          )),
      ],
    );
  }

  void setMeetingListeners(Room _meeting) {
    // Called when participant joined meeting
    _meeting.on(
      Events.participantJoined,
      (Participant participant) {
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

    _meeting.on(Events.presenterChanged, (presenterId) {
      setState(() {
        presenterId = presenterId;
        isPresenting = presenterId != null;
        updateOnScreenParticipants();
      });
    });

    _meeting.localParticipant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == "share") {
        setState(() {
          isPresenting = true;
          updateOnScreenParticipants();
        });
      }
    });
    _meeting.localParticipant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == "share") {
        setState(() {
          isPresenting = false;
          updateOnScreenParticipants();
        });
      }
    });
  }

  updateOnScreenParticipants() {
    gridInfo = ManageGrid.getGridRowsAndColumns(
        participantsCount: participants.length,
        device: ResponsiveValue<device_type>(context, conditionalValues: [
          Condition.equals(name: MOBILE, value: device_type.mobile),
          Condition.equals(name: TABLET, value: device_type.tablet),
          Condition.largerThan(name: TABLET, value: device_type.desktop),
        ]).value!,
        isPresenting: isPresenting);

    Map<int, List<Participant>> newParticipants =
        ManageGrid.getGridForMainParticipants(
            participants: participants, gridInfo: gridInfo);

    List<Participant> participantList = [];
    if (activeSpeakerList == null) {
      newParticipants.values.forEach((element) {
        element.forEach((participant) {
          participantList.add(participant);
        });
      });
    } else {
      activeSpeakerList!.values.forEach((element) {
        element.forEach((participant) {
          participantList.add(participant);
        });
      });
    }

    int maxNoOfParticipant = isPresenting ? 2 : 6;

    if (participants.length > maxNoOfParticipant) {
      if (activeSpeakerId != null &&
          widget.meeting.localParticipant.id != activeSpeakerId &&
          !participantList
              .contains(widget.meeting.participants[activeSpeakerId])) {
        newParticipants.values.last
            .removeAt(newParticipants.values.last.length - 1);
        newParticipants.values.last.add(participants.values
            .firstWhere((element) => element.id == activeSpeakerId));
        activeSpeakerList = newParticipants;
      }
    }

    if (activeSpeakerList == null) {
      activeSpeakerList = newParticipants;
    }

    int activeSpeakerListLength = 0;
    int newParticipantListLength = 0;

    activeSpeakerList!.keys.forEach((key) {
      List<Participant> participants = activeSpeakerList![key]!;
      int length = participants.length;
      activeSpeakerListLength += length;
    });

    newParticipants.keys.forEach((key) {
      List<Participant> participants = newParticipants[key]!;
      int length = participants.length;
      newParticipantListLength += length;
    });

    if (activeSpeakerListLength != newParticipantListLength) {
      activeSpeakerList = newParticipants;
    }

    if (!listEquals(activeSpeakerList!.values.toList(),
        onScreenParticipants.values.toList())) {
      setState(() {
        onScreenParticipants = activeSpeakerList!;
      });
    }
  }
}
