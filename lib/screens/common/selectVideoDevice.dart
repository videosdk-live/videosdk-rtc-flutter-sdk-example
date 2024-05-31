// // ignore_for_file: non_constant_identifier_names, dead_code

// // Join Screen
// import 'package:flutter/material.dart';
// import 'package:videosdk/videosdk.dart';
// import '../../constants/colors.dart';

// class DropdownsWidget extends StatefulWidget {
//   final bool? isMicrophonePermissionAllowed;
//   AudioDeviceInfo? selectedAudioOutputDevice;
//   List<AudioDeviceInfo>? audioDevices;
//   final Function(AudioDeviceInfo?) onAudioDeviceSelected;

//   DropdownsWidget({
//     Key? key,
//     required this.isMicrophonePermissionAllowed,
//     this.selectedAudioOutputDevice,
//     this.audioDevices,
//     required this.onAudioDeviceSelected,
//   }) : super(key: key);

//   @override
//   State<DropdownsWidget> createState() => _DropdownsWidgetState();
// }

// class _DropdownsWidgetState extends State<DropdownsWidget> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(30.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           DropdownButtonFormField(
//             isExpanded: true,
//             dropdownColor: black600,
//             borderRadius: BorderRadius.circular(12.0),
//             decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 filled: true,
//                 fillColor: black600,
//                 labelText: 'Speaker',
//                 labelStyle: TextStyle(color: Colors.white, fontSize: 18),
//                 //enabledBorder: InputBorder.none,
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                   borderSide: const BorderSide(
//                     color: Colors.white,
//                   ),
//                 ),
//                 focusColor: Colors.white),
//             value: widget.selectedAudioOutputDevice,
//             hint: Text(
//               "Permission Denied",
//               style: TextStyle(fontSize: 15, color: black500),
//             ),
//             icon: const Icon(Icons.keyboard_arrow_down),
//             elevation: 16,
//             style: const TextStyle(color: Colors.white, fontSize: 15),
//             onChanged: (AudioDeviceInfo? value) {
//               setState(() {
//                 widget.selectedAudioOutputDevice = value;
//               });
//               widget.onAudioDeviceSelected(value);
//             },
//             items: widget.audioDevices?.map((AudioDeviceInfo device) {
//               return DropdownMenuItem<AudioDeviceInfo>(
//                 value: device,
//                 child: Text(
//                   device.label,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:videosdk/videosdk.dart';
// import '../../constants/colors.dart';

// class SelectAudioOutput extends StatefulWidget {
//   final bool? isMicrophonePermissionAllowed;
//   AudioDeviceInfo? selectedAudioOutputDevice;
//   List<AudioDeviceInfo>? audioDevices;
//   final Function(AudioDeviceInfo?) onAudioDeviceSelected;

//   SelectAudioOutput({
//     Key? key,
//     required this.isMicrophonePermissionAllowed,
//     this.selectedAudioOutputDevice,
//     this.audioDevices,
//     required this.onAudioDeviceSelected,
//   }) : super(key: key);

//   @override
//   State<SelectAudioOutput> createState() => _SelectAudioOutputState();
// }

// class _SelectAudioOutputState extends State<SelectAudioOutput> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           widget.audioDevices != null &&
//                   widget.audioDevices!.isNotEmpty &&
//                   widget.isMicrophonePermissionAllowed == true
//               ? ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: widget.audioDevices!.length + 1, // Add one for "Cancel"
//                   itemBuilder: (context, index) {
//                     if (index == widget.audioDevices!.length) {
//                       return ListTile(
//                         leading: Icon(Icons.close, color: Colors.white),
//                         title: Text(
//                           "Cancel",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                       );
//                     } else {
//                       AudioDeviceInfo device = widget.audioDevices![index];
//                       return ListTile(
//                         leading: widget.selectedAudioOutputDevice == device ? Icon(Icons.check, color: Colors.white) : null ,
//                         title: Text(
//                           device.label,
//                           style: TextStyle(
//                             color:Colors.white,
//                           ),
//                         ),
//                         onTap: () {
//                           setState(() {
//                             widget.selectedAudioOutputDevice = device;
//                           });
//                           widget.onAudioDeviceSelected(device);
//                         },
//                       );
//                     }
//                   },
//                 )
//               : Text(
//                   "Permission Denied",
//                   style: TextStyle(fontSize: 15, color: black500),
//                 ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import '../../constants/colors.dart';

class SelectVideoDevice extends StatefulWidget {
    final bool? isCameraPermissionAllowed;
  VideoDeviceInfo? selectedVideoDevice;
  List<VideoDeviceInfo>? videoDevices;
  final Function(VideoDeviceInfo?) onVideoDeviceSelected;

  SelectVideoDevice({
    Key? key,
    required this.isCameraPermissionAllowed,
    this.selectedVideoDevice,
    this.videoDevices,
    required this.onVideoDeviceSelected,
  }) : super(key: key);

  @override
  State<SelectVideoDevice> createState() => _SelectVideoDeviceState();
}

class _SelectVideoDeviceState extends State<SelectVideoDevice> {
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
        children: [
          widget.videoDevices != null &&
                  widget.videoDevices!.isNotEmpty &&
                  widget.isCameraPermissionAllowed == true
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.videoDevices!.length + 1, 
                  itemBuilder: (context, index) {
                    if (index == widget.videoDevices!.length) {
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
                      VideoDeviceInfo device = widget.videoDevices![index];
                      return ListTile(
                        leading: widget.selectedVideoDevice == device
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
                            widget.selectedVideoDevice = device;
                          });
                          widget.onVideoDeviceSelected(device);
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
