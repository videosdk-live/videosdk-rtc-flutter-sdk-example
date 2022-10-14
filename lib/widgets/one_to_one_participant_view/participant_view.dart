import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/widgets/one_to_one_participant_view/local_screen_share_view.dart';

class ParticipantView extends StatelessWidget {
  Stream? stream;
  bool isMicOn = false;
  Color? avatarBackground;
  String participantName = "A";
  bool isLocalScreenShare;
  bool isScreenShare;
  double avatarTextSize;
  Function() onStopScreeenSharePressed;
  ParticipantView(
      {Key? key,
      required this.stream,
      required this.isMicOn,
      required this.avatarBackground,
      required this.participantName,
      this.isLocalScreenShare = false,
      this.avatarTextSize = 50,
      required this.isScreenShare,
      required this.onStopScreeenSharePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        stream != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RTCVideoView(
                  stream?.renderer as RTCVideoRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              )
            : Center(
                child: !isLocalScreenShare
                    ? Container(
                        padding: EdgeInsets.all(avatarTextSize / 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: avatarBackground,
                        ),
                        child: Text(
                          participantName.characters.first.toUpperCase(),
                          style: TextStyle(fontSize: avatarTextSize),
                        ),
                      )
                    : LocalScreenShareView(
                        onStopScreeenSharePressed: onStopScreeenSharePressed,
                      )),
        if (!isMicOn)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: black700,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.mic_off,
                  size: avatarTextSize / 2,
                )),
          ),
        if (isScreenShare)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: black700,
              ),
              child: Text(isScreenShare
                  ? "${isLocalScreenShare ? "You" : participantName} is presenting"
                  : participantName),
            ),
          ),
      ],
    );
  }
}
