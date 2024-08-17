// // ignore_for_file: non_constant_identifier_names, dead_code

import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import '../../constants/colors.dart';

class SelectAudioOutput extends StatefulWidget {
  final bool? isMicrophonePermissionAllowed;
  AudioDeviceInfo? selectedAudioOutputDevice;
  List<AudioDeviceInfo>? audioDevices;
  final Function(AudioDeviceInfo?) onAudioDeviceSelected;

  SelectAudioOutput({
    Key? key,
    required this.isMicrophonePermissionAllowed,
    this.selectedAudioOutputDevice,
    this.audioDevices,
    required this.onAudioDeviceSelected,
  }) : super(key: key);

  @override
  State<SelectAudioOutput> createState() => _SelectAudioOutputState();
}

class _SelectAudioOutputState extends State<SelectAudioOutput> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.audioDevices != null &&
                  widget.audioDevices!.isNotEmpty &&
                  widget.isMicrophonePermissionAllowed == true
              ? ListView.builder(
                  shrinkWrap: true,
                  physics:
                      NeverScrollableScrollPhysics(), 
                  itemCount: widget.audioDevices!.length + 1,
                  itemBuilder: (context, index) {
                    if (index == widget.audioDevices!.length) {
                      return ListTile(
                        leading: Icon(Icons.close, color: Colors.white),
                        title: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      );
                    } else {
                      AudioDeviceInfo device = widget.audioDevices![index];
                      return ListTile(
                        leading: widget.selectedAudioOutputDevice == device
                            ? Icon(Icons.check, color: Colors.white)
                            : SizedBox(width: 24),
                        title: Text(
                          device.label,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.selectedAudioOutputDevice = device;
                          });
                          widget.onAudioDeviceSelected(device);
                          Navigator.pop(context);
                        },
                      );
                    }
                  },
                )
              : Text(
                  "Permission Denied",
                  style: TextStyle(fontSize: 15, color: black500),
                ),
        ],
      ),
    );
  }
}
