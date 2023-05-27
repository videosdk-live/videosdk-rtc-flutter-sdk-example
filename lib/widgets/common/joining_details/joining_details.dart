import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/utils/spacer.dart';
import 'package:videosdk_flutter_example/utils/toast.dart';

class JoiningDetails extends StatefulWidget {
  final bool isCreateMeeting;
  final Function onClickMeetingJoin;

  const JoiningDetails(
      {Key? key,
      required this.isCreateMeeting,
      required this.onClickMeetingJoin})
      : super(key: key);

  @override
  State<JoiningDetails> createState() => _JoiningDetailsState();
}

class _JoiningDetailsState extends State<JoiningDetails> {
  String _meetingId = "";
  String _displayName = "";
  String meetingMode = "GROUP";
  List<String> meetingModes = ["ONE_TO_ONE", "GROUP"];
  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: black750),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: meetingMode,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 16,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.white),
              onChanged: (String? value) {
                setState(() {
                  meetingMode = value!;
                });
              },
              borderRadius: BorderRadius.circular(12),
              dropdownColor: black750,
              alignment: AlignmentDirectional.centerStart,
              items: meetingModes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth:
                          ResponsiveValue<double>(context, conditionalValues: [
                        Condition.equals(name: MOBILE, value: maxWidth / 1.5),
                        Condition.equals(name: TABLET, value: maxWidth / 1.5),
                        const Condition.equals(name: DESKTOP, value: 595),
                      ]).value!,
                    ),
                    child: Text(
                      value == "GROUP" ? "Group Call" : "One to One Call",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const VerticalSpacer(16),
        if (!widget.isCreateMeeting)
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: black750),
            child: TextField(
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              onChanged: ((value) => _meetingId = value),
              decoration: InputDecoration(
                  constraints: BoxConstraints.tightFor(
                    width: ResponsiveValue<double>(context, conditionalValues: [
                      Condition.equals(name: MOBILE, value: maxWidth /1.3),
                      Condition.equals(name: TABLET, value: maxWidth / 1.3),
                      const Condition.equals(name: DESKTOP, value: 640),
                    ]).value!,
                  ),
                  hintText: "Enter meeting code",
                  hintStyle: const TextStyle(
                    color: textGray,
                  ),
                  border: InputBorder.none),
            ),
          ),
        if (!widget.isCreateMeeting) const VerticalSpacer(16),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: black750),
          child: TextField(
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
            onChanged: ((value) => _displayName = value),
            decoration: InputDecoration(
                constraints: BoxConstraints.tightFor(
                  width: ResponsiveValue<double>(context, conditionalValues: [
                    Condition.equals(name: MOBILE, value: maxWidth / 1.3),
                    Condition.equals(name: TABLET, value: maxWidth / 1.3),
                    const Condition.equals(name: DESKTOP, value: 640),
                  ]).value!,
                ),
                hintText: "Enter your name",
                hintStyle: const TextStyle(
                  color: textGray,
                ),
                border: InputBorder.none),
          ),
        ),
        const VerticalSpacer(16),
        MaterialButton(
            minWidth: ResponsiveValue<double>(context, conditionalValues: [
              Condition.equals(name: MOBILE, value: maxWidth /1.3),
              Condition.equals(name: TABLET, value: maxWidth / 1.3),
              const Condition.equals(name: DESKTOP, value: 650),
            ]).value!,
            height: 50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: purple,
            child: const Text("Join Meeting", style: TextStyle(fontSize: 16)),
            onPressed: () {
              if (_displayName.trim().isEmpty) {
                showSnackBarMessage(
                    message: "Please enter name", context: context);
                return;
              }
              if (!widget.isCreateMeeting && _meetingId.trim().isEmpty) {
                showSnackBarMessage(
                    message: "Please enter meeting id", context: context);
                return;
              }
              widget.onClickMeetingJoin(
                  _meetingId.trim(), meetingMode, _displayName.trim());
            }),
      ],
    );
  }
}
