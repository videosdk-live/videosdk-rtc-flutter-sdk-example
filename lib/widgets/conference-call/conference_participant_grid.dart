import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/widgets/conference-call/manage_grid.dart';
import 'package:videosdk_flutter_example/widgets/conference-call/participant_grid.dart';
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
  int numberOfMaxOnScreenParticipants = 16;
  String quality = "high";

  Map<String, Participant> participants = {};
  Map<String, Participant> onScreenParticipants = {};
  Map<int, List<Participant>> onShowParticipants = {};
  Map<String, int>? gridInfo;

  @override
  void initState() {
    localParticipant = widget.meeting.localParticipant;
    participants.putIfAbsent(localParticipant.id, () => localParticipant);
    participants.addAll(widget.meeting.participants);
    presenterId = widget.meeting.activePresenterId;

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
    // return GridView.count(
    //   crossAxisCount: 4,
    //   children: [
    //     ...participants.values
    //         .map((participant) => ParticipantGridTile(
    //               key: Key(participant.id),
    //               participant: participant,
    //               activeSpeakerId: activeSpeakerId,
    //               quality: quality,
    //             ))
    //         .toList()
    //   ],
    // );

    return particiapant_grid(
      onShowParticipants: onShowParticipants,
      activeSpeakerId: activeSpeakerId,
      quality: quality,
    );

    //  return onShowParticipants.length == 1 &&
    //     onShowParticipants.values.first.length <= 2
    // ? Flex(
    //     direction: ResponsiveValue<Axis>(context, conditionalValues: [
    //       const Condition.equals(name: MOBILE, value: Axis.horizontal),
    //       const Condition.largerThan(name: MOBILE, value: Axis.vertical),
    //     ]).value!,
    //     children: [
    //       for (int i = 0; i < onShowParticipants.length; i++)
    //         Flexible(
    //             child: Flex(
    //           direction: ResponsiveValue<Axis>(context, conditionalValues: [
    //             const Condition.equals(name: MOBILE, value: Axis.vertical),
    //             const Condition.largerThan(
    //                 name: MOBILE, value: Axis.horizontal),
    //           ]).value!,
    //           children: [
    //             for (int j = 0; j < onShowParticipants[i]!.length; j++)
    //               Flexible(
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(4.0),
    //                   child: ParticipantGridTile(
    //                       key: Key(onShowParticipants[i]![j].id),
    //                       participant: onShowParticipants[i]![j],
    //                       activeSpeakerId: activeSpeakerId,
    //                       quality: quality),
    //                 ),
    //               )
    //           ],
    //         )),
    //     ],
    //   )
    // :
    // : Container(
    //     margin: const EdgeInsets.all(15),
    //     child: Column(
    //       children: [
    //       for (int i = 0; i < onShowParticipants.length; i++)
    //         Flexible(
    //             child: Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             for (int j = 0; j < onShowParticipants[i]!.length; j++)
    //               Flexible(
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(4.0),
    //                   child: ParticipantGridTile(
    //                       key: Key(onShowParticipants[i]![j].id),
    //                       participant: onShowParticipants[i]![j],
    //                       activeSpeakerId: activeSpeakerId,
    //                       quality: quality),
    //                 ),
    //               )
    //           ],
    //         )),
    //     ],
    //   ),
    // );
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

    _meeting.on(Events.presenterChanged, (_presenterId) {
      setState(() {
        presenterId = _presenterId;
        numberOfMaxOnScreenParticipants = _presenterId != null ? 2 : 6;
        updateOnScreenParticipants();
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

  // updateOnScreenParticipants() {
  //   Map<String, Participant> newScreenParticipants = <String, Participant>{};

  //   participants.values
  //       .toList()
  //       .sublist(
  //           0,
  //           participants.length > numberOfMaxOnScreenParticipants
  //               ? numberOfMaxOnScreenParticipants
  //               : participants.length)
  //       .forEach((participant) {
  //     newScreenParticipants.putIfAbsent(participant.id, () => participant);
  //   });
  //   if (!newScreenParticipants.containsKey(activeSpeakerId) &&
  //       activeSpeakerId != null) {
  //     newScreenParticipants.remove(newScreenParticipants.keys.last);
  //     newScreenParticipants.putIfAbsent(
  //         activeSpeakerId!,
  //         () => participants.values
  //             .firstWhere((element) => element.id == activeSpeakerId));
  //   }
  //   if (!listEquals(newScreenParticipants.keys.toList(),
  //       onScreenParticipants.keys.toList())) {
  //     setState(() {
  //       onScreenParticipants = newScreenParticipants;
  //       quality = newScreenParticipants.length > 4
  //           ? "low"
  //           : newScreenParticipants.length > 2
  //               ? "medium"
  //               : "high";
  //     });
  //   }
  //   if (numberofColumns !=
  //       (newScreenParticipants.length > 2 ||
  //               numberOfMaxOnScreenParticipants == 2
  //           ? 2
  //           : 1)) {
  //     setState(() {
  //       numberofColumns = newScreenParticipants.length > 2 ||
  //               numberOfMaxOnScreenParticipants == 2
  //           ? 2
  //           : 1;
  //     });
  //   }`
  // }

  updateOnScreenParticipants() {
    gridInfo = ManageGrid.getGridRowsAndColumns(
        participantsCount: participants.length,
        device: ResponsiveValue<device_type>(context, conditionalValues: [
          const Condition.equals(name: MOBILE, value: device_type.mobile),
          const Condition.equals(name: TABLET, value: device_type.tablet),
          const Condition.largerThan(name: TABLET, value: device_type.desktop),
        ]).value!);

    setState(() {
      onShowParticipants = ManageGrid.getGridForMainParticipants(
          participants: participants, gridInfo: gridInfo);
      quality = onShowParticipants.values.length >= 3
          ? "low"
          : onShowParticipants.values.length > 2
              ? "med"
              : "high";
    });

    if (participants.length > 6) {
      onShowParticipants.values.forEach((participantList) {
        participantList.forEach((element) {
          if (element.id != activeSpeakerId && activeSpeakerId != null) {
            setState(() {
              participantList.remove(element);
              participantList.add(participants.values
                  .firstWhere((element) => element.id == activeSpeakerId));
            });
          }
        });
      });
    }
  }
}
