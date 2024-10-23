// ignore_for_file: non_constant_identifier_names, dead_code


import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import '../../../constants/colors.dart';

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
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.videoDevices != null &&
                  widget.videoDevices!.isNotEmpty &&
                  widget.isCameraPermissionAllowed == true
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), 
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
