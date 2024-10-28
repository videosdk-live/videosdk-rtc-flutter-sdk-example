// ignore_for_file: non_constant_identifier_names, dead_code

// Join Screen
import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import '../../../constants/colors.dart';

class DropdownsWebWidget extends StatefulWidget {
  final bool? isCameraPermissionAllowed, isMicrophonePermissionAllowed;
  VideoDeviceInfo? selectedVideoDevice;
  AudioDeviceInfo? selectedAudioOutputDevice;
  AudioDeviceInfo? selectedAudioInputDevice;

  List<VideoDeviceInfo>? videoDevices;
  List<AudioDeviceInfo>? audioInputDevices;
  List<AudioDeviceInfo>? audioOutputDevices;

  final Function(AudioDeviceInfo?) onAudioOutputDeviceSelected;
  final Function(AudioDeviceInfo?) onAudioInputDeviceSelected;

  final Function(VideoDeviceInfo?) onVideoDeviceSelected;

  DropdownsWebWidget({
    Key? key,
    required this.isCameraPermissionAllowed,
    required this.isMicrophonePermissionAllowed,
    this.selectedAudioOutputDevice,
    this.selectedAudioInputDevice,
    this.selectedVideoDevice,
    this.audioInputDevices,
    this.audioOutputDevices,
    this.videoDevices,
    required this.onAudioOutputDeviceSelected,
    required this.onAudioInputDeviceSelected,
    required this.onVideoDeviceSelected,
  }) : super(key: key);

  @override
  State<DropdownsWebWidget> createState() => _DropdownsWidgetState();
}

class _DropdownsWidgetState extends State<DropdownsWebWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField(
            isExpanded: true,
            dropdownColor: black750,
            borderRadius: BorderRadius.circular(12.0),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: EdgeInsets.fromLTRB(10, 13, 0, 13),
                isDense: true,
                filled: true,
                fillColor: black750,
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
                child: Text(device.label,overflow: TextOverflow.ellipsis,),
              );
            }).toList(),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: DropdownButtonFormField(
            isExpanded: true,
            dropdownColor: black750,
            borderRadius: BorderRadius.circular(12.0),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: EdgeInsets.fromLTRB(10, 13, 0, 13),
                isDense: true,
                filled: true,
                fillColor: black750,
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
              widget.onAudioOutputDeviceSelected(value);
            },
            items: widget.audioOutputDevices?.map((AudioDeviceInfo device) {
              return DropdownMenuItem<AudioDeviceInfo>(
                value: device,
                child: Text(device.label,overflow: TextOverflow.ellipsis,),
              );
            }).toList(),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: DropdownButtonFormField(
            isExpanded: true,
            dropdownColor: black750,
            borderRadius: BorderRadius.circular(12.0),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: EdgeInsets.fromLTRB(10, 13, 0, 13),
                isDense: true,
                filled: true,
                fillColor: black750,
                labelText: 'Microphone',
                labelStyle: TextStyle(color: Colors.white, fontSize: 18),
                //enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Colors.white,
                  ),
                ),
                focusColor: Colors.white),
            value: widget.selectedAudioInputDevice,
            hint: Text(
              "Permission Denied",
              style: TextStyle(fontSize: 15, color: black500),
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            elevation: 16,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            onChanged: (AudioDeviceInfo? value) {
              setState(() {
                widget.selectedAudioInputDevice = value;
              });
              widget.onAudioInputDeviceSelected(value);
            },
            items: widget.audioInputDevices?.map((AudioDeviceInfo device) {
              return DropdownMenuItem<AudioDeviceInfo>(
                value: device,
                child: Text(device.label,overflow: TextOverflow.ellipsis,),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
