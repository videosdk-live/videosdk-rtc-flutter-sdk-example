import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';

class JoinView extends StatelessWidget {
  final RTCVideoRenderer? cameraRenderer;
  final bool isMicOn;
  final bool isCameraOn;
  final VoidCallback onMicToggle;
  final VoidCallback onCameraToggle;

  const JoinView({
    Key? key,
    required this.cameraRenderer,
    required this.isMicOn,
    required this.isCameraOn,
    required this.onMicToggle,
    required this.onCameraToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            double aspectRatio =
                ResponsiveValue<double>(context, conditionalValues: [
              Condition.equals(name: MOBILE, value: 1 / 1.5),
              Condition.equals(name: TABLET, value: 16 / 10),
              Condition.largerThan(name: TABLET, value: 16 / 9),
            ]).value!;
            double height =
                ResponsiveValue<double>(context, conditionalValues: [
              Condition.equals(name: MOBILE, value: 400),
              Condition.equals(
                  name: TABLET, value: constraints.maxWidth / aspectRatio),
              Condition.largerThan(
                  name: TABLET, value: constraints.maxWidth / aspectRatio),
            ]).value!;
            double width = ResponsiveValue<double>(context, conditionalValues: [
              Condition.equals(
                  name: MOBILE, value: constraints.maxWidth * 0.7),
              Condition.equals(name: TABLET, value: constraints.maxWidth),
              Condition.largerThan(name: TABLET, value: constraints.maxWidth),
            ]).value!;

            return SizedBox(
              height: height,
              width: width,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  AspectRatio(
                    aspectRatio: aspectRatio,
                    child: cameraRenderer != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: RTCVideoView(
                              cameraRenderer as RTCVideoRenderer,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: black800,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Center(
                              child: Text(
                                "Camera is turned off",
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 20, 
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: onMicToggle,
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: EdgeInsets.all(
                                ResponsiveValue<double>(context,
                                    conditionalValues: [
                                      Condition.equals(name: MOBILE, value: 12),
                                      Condition.equals(name: TABLET, value: 15),
                                      Condition.equals(
                                          name: DESKTOP, value: 18),
                                    ]).value!,
                              ),
                              backgroundColor: isMicOn ? Colors.white : red,
                              foregroundColor: Colors.black,
                            ),
                            child: Icon(isMicOn ? Icons.mic : Icons.mic_off,
                                color: isMicOn ? grey : Colors.white),
                          ),
                          ElevatedButton(
                            onPressed: onCameraToggle,
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: EdgeInsets.all(
                                ResponsiveValue<double>(context,
                                    conditionalValues: [
                                      Condition.equals(name: MOBILE, value: 12),
                                      Condition.equals(name: TABLET, value: 15),
                                      Condition.equals(
                                          name: DESKTOP, value: 18),
                                    ]).value!,
                              ),
                              backgroundColor: isCameraOn ? Colors.white : red,
                            ),
                            child: Icon(
                              isCameraOn ? Icons.videocam : Icons.videocam_off,
                              color: isCameraOn ? grey : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}