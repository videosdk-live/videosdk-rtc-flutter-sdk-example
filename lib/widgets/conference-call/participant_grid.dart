import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/widgets/conference-call/participant_grid_tile.dart';

class particiapant_grid extends StatelessWidget {
  const particiapant_grid({
    Key? key,
    required this.onShowParticipants,
    required this.activeSpeakerId,
    required this.quality,
  }) : super(key: key);

  final Map<int, List<Participant>> onShowParticipants;
  final String? activeSpeakerId;
  final String quality;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Column(
          children: onShowParticipants.entries
              .map(
                (e) => Flexible(
                    key: Key(e.key.toString()),
                    child: Row(
                      children: e.value
                          .map((
                            ep,
                          ) =>
                              Flexible(
                                key: Key(ep.id),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ParticipantGridTile(
                                      // key: Key(ep.id),
                                      participant: ep,
                                      activeSpeakerId: activeSpeakerId,
                                      quality: quality),
                                ),
                              ))
                          .toList(),
                    )),
              )
              .toList()

          // children: [

          //   for (int i = 0; i < onShowParticipants.length; i++)
          //     Flexible(
          //         child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         for (int j = 0; j < onShowParticipants[i]!.length; j++)
          //           Flexible(
          //             child: Padding(
          //               padding: const EdgeInsets.all(4.0),
          //               child: ParticipantGridTile(
          //                   key: Key(onShowParticipants[i]![j].id),
          //                   participant: onShowParticipants[i]![j],
          //                   activeSpeakerId: activeSpeakerId,
          //                   quality: quality),
          //             ),
          //           )
          //       ],
          //     )),
          // ],
          ),
    );
  }
}
