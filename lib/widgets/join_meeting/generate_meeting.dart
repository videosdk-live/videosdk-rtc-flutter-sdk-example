import 'package:flutter/material.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/utils/spacer.dart';
import 'package:videosdk_flutter_example/utils/toast.dart';

class GenerateMeetingWidget extends StatefulWidget {
  bool isCreateMeeting;
  Function onClickMeetingJoin;

  GenerateMeetingWidget(
      {Key? key,
      required this.isCreateMeeting,
      required this.onClickMeetingJoin})
      : super(key: key);

  @override
  State<GenerateMeetingWidget> createState() => _GenerateMeetingWidgetState();
}

class _GenerateMeetingWidgetState extends State<GenerateMeetingWidget> {
  String _meetingId = "";
  String _displayName = "";
  String _callType = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.isCreateMeeting)
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: black750),
            child: TextField(
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
              onChanged: ((value) => _meetingId = value),
              decoration: const InputDecoration(
                  hintText: "Enter meeting code",
                  hintStyle: TextStyle(
                    color: textGray,
                  ),
                  border: InputBorder.none),
            ),
          ),
        const VerticalSpacer(16),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: black750),
          child: TextField(
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
            onChanged: ((value) => _displayName = value),
            decoration: const InputDecoration(
                hintText: "Enter your name",
                hintStyle: TextStyle(
                  color: textGray,
                ),
                border: InputBorder.none),
          ),
        ),
        const VerticalSpacer(16),
        MaterialButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: purple,
            child: const Text("Join Meeting", style: TextStyle(fontSize: 16)),
            onPressed: () {
              if (_displayName.isEmpty) {
                showSnackBarMessage(
                    message: "Please enter name", context: context);
                return;
              }
              if (!widget.isCreateMeeting && _meetingId.isEmpty) {
                showSnackBarMessage(
                    message: "Please meeting id", context: context);
                return;
              }
              widget.onClickMeetingJoin(_meetingId, _callType, _displayName);
            }),
      ],
    );
  }
}
