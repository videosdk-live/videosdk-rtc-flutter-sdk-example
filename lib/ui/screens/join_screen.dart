import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../widgets/meeting_controls/meeting_action_button.dart';
import 'meeting_screen.dart';

class JoinScreen extends StatefulWidget {
  final String meetingId;
  final String token;

  const JoinScreen({
    Key? key,
    required this.meetingId,
    required this.token,
  }) : super(key: key);

  @override
  _JoinScreenState createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  String displayName = "";
  bool isMicOn = true;
  bool isWebcamOn = true;

  CameraController? cameraController;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      int selectedCameraId = availableCameras.length > 1 ? 1 : 0;

      cameraController = CameraController(
        availableCameras[selectedCameraId],
        ResolutionPreset.medium,
      );

      cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }).catchError((err) {
      log("Error: $err");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VideoSDK RTC"),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 7),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 1.5),
                height: (MediaQuery.of(context).size.height / 2.5),
                child: !(cameraController?.value.isInitialized ?? false)
                    ? Container()
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          AspectRatio(
                            aspectRatio: cameraController!.value.aspectRatio,
                            child: CameraPreview(cameraController!),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                MeetingActionButton(
                                  icon: isMicOn ? Icons.mic : Icons.mic_off,
                                  color: isMicOn
                                      ? Theme.of(context).primaryColor
                                      : Colors.red,
                                  onClick: () => setState(
                                    () => isMicOn = !isMicOn,
                                  ),
                                ),
                                MeetingActionButton(
                                  color: isWebcamOn
                                      ? Theme.of(context).primaryColor
                                      : Colors.red,
                                  onClick: () {
                                    if (isWebcamOn) {
                                      cameraController?.pausePreview();
                                    } else {
                                      cameraController?.resumePreview();
                                    }
                                    setState(() => isWebcamOn = !isWebcamOn);
                                  },
                                  icon: isWebcamOn
                                      ? Icons.videocam
                                      : Icons.videocam_off,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextField(
                  onChanged: ((value) => displayName = value),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Name",
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    prefixIcon: Icon(
                      Icons.keyboard,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () async {
                  if (displayName.isEmpty) {
                    displayName = "Guest";
                  }

                  await cameraController?.dispose();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MeetingScreen(
                        token: widget.token,
                        meetingId: widget.meetingId,
                        displayName: displayName,
                        micEnabled: isMicOn,
                        webcamEnabled: isWebcamOn,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "JOIN",
                ),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
