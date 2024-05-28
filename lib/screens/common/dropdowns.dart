// ignore_for_file: non_constant_identifier_names, dead_code

// Join Screen
import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import '../../constants/colors.dart';

class DropdownsWidget extends StatefulWidget {
  final bool? isCameraPermissionAllowed, isMicrophonePermissionAllowed;
  VideoDeviceInfo? selectedVideoDevice;
  AudioDeviceInfo? selectedAudioOutputDevice;
  List<VideoDeviceInfo>? videoDevices;
  List<AudioDeviceInfo>? audioDevices;
  final Function(AudioDeviceInfo?) onAudioDeviceSelected;
  final Function(VideoDeviceInfo?) onVideoDeviceSelected;

  DropdownsWidget({
    Key? key,
    required this.isCameraPermissionAllowed,
    required this.isMicrophonePermissionAllowed,
    this.selectedAudioOutputDevice,
    this.selectedVideoDevice,
    this.audioDevices,
    this.videoDevices,
    required this.onAudioDeviceSelected,
    required this.onVideoDeviceSelected,
  }) : super(key: key);

  @override
  State<DropdownsWidget> createState() => _DropdownsWidgetState();
}

class _DropdownsWidgetState extends State<DropdownsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DropdownButtonFormField(
            isExpanded: true,
            dropdownColor: black600,
            borderRadius: BorderRadius.circular(12.0),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: black600,
                labelText: 'Camera',
                labelStyle: TextStyle(color: Colors.white, fontSize: 18),
                //enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Colors.white,
                  ),
                ),
                focusColor: Colors.white),
            value: widget.selectedVideoDevice,
            hint: Text(
              "Permission Denied",
              style: TextStyle(fontSize: 15, color: black500),
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            elevation: 16,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            onChanged: (VideoDeviceInfo? value) {
              setState(() {
                widget.selectedVideoDevice = value;
              });
              widget.onVideoDeviceSelected(value);
            },
            items: widget.videoDevices?.map((VideoDeviceInfo device) {
              return DropdownMenuItem<VideoDeviceInfo>(
                value: device,
                child: Text(
                  device.label,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
          const SizedBox(
            height: 30,
          ),
          DropdownButtonFormField(
            isExpanded: true,
            dropdownColor: black600,
            borderRadius: BorderRadius.circular(12.0),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: black600,
                labelText: 'Speaker',
                labelStyle: TextStyle(color: Colors.white, fontSize: 18),
                //enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Colors.white,
                  ),
                ),
                focusColor: Colors.white),
            value: widget.selectedAudioOutputDevice,
            hint: Text(
              "Permission Denied",
              style: TextStyle(fontSize: 15, color: black500),
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            elevation: 16,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            onChanged: (AudioDeviceInfo? value) {
              setState(() {
                widget.selectedAudioOutputDevice = value;
              });
              widget.onAudioDeviceSelected(value);
            },
            items: widget.audioDevices?.map((AudioDeviceInfo device) {
              return DropdownMenuItem<AudioDeviceInfo>(
                value: device,
                child: Text(
                  device.label,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
