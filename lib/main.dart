import 'package:example/ui/meeting_actions.dart';
import 'package:example/ui/utils/navigator_key.dart';
import './ui/localParticipant/local_participant.dart';
import './ui/remoteParticipants/list_remote_participants.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:videosdk/rtc.dart';
import 'package:videosdk/meeting.dart';
import 'package:videosdk/participant.dart';
import 'package:http/http.dart' as http;

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VideoSDK Flutter Example',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: MyHomePage(title: 'VideoSDK Flutter Example'),
      navigatorKey: navigatorKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, Participant> participants = new Map();
  Participant? localParticipant;
  Meeting? meeting;

  String? activeSpeakerId;
  String? activePresenterId;

  String? meetingId;
  String? token;

  _MyHomePageState() {
    this.localParticipant = null;
    this.activeSpeakerId = null;
    this.activePresenterId = null;

    this._fetchMeetingIdAndToken();
  }

  _handleMeetingListners(Meeting meeting) {
    meeting.on(
      "participant-joined",
      (Participant participant) {
        final newParticipants = participants;
        newParticipants[participant.id] = participant;
        setState(() {
          participants = newParticipants;
        });
      },
    );
    //
    meeting.on(
      "participant-left",
      (participantId) {
        final newParticipants = participants;

        newParticipants.remove(participantId);
        setState(() {
          participants = newParticipants;
        });
      },
    );
    //
    meeting.on('meeting-left', () {
      setState(() {
        token = null;
        meetingId = null;
      });
    });
    meeting.on('speaker-changed', (_activeSpeakerId) {
      setState(() {
        activeSpeakerId = _activeSpeakerId;
      });
      print("meeting speaker-changed => ${_activeSpeakerId}");
    });
    //
    meeting.on('presenter-changed', (_activePresenterId) {
      setState(() {
        activePresenterId = _activePresenterId;
      });
      print("meeting presenter-changed => ${_activePresenterId}");
    });
  }

  void _fetchMeetingIdAndToken() async {
    final String API_SERVER_HOST = "http://127.0.0.1:9000";

    final Uri getTokenUrl = Uri.parse('$API_SERVER_HOST/get-token');
    final http.Response tokenResponse = await http.get(getTokenUrl);

    final dynamic _token = json.decode(tokenResponse.body)['token'];

    // final Uri getMeetingIdUrl = Uri.parse('$API_SERVER_HOST/create-meeting/');

    // final http.Response meetingIdResponse =
    //     await http.post(getMeetingIdUrl, body: {"token": _token});

    // final _meetingId = json.decode(meetingIdResponse.body)['meetingId'];

    setState(() {
      token = _token;
      meetingId = "d6c2-y6xf-ku84"; // _meetingId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return meetingId != null && token != null
        ? MeetingBuilder(
            meetingId: meetingId as String,
            displayName: "Chintan Rajpara",
            token: token as String,
            micEnabled: false,
            webcamEnabled: false,
            builder: (_meeting) {
              _meeting.on(
                "meeting-joined",
                () {
                  setState(
                    () {
                      localParticipant = _meeting.localParticipant;
                      meeting = _meeting;
                    },
                  );
                  _handleMeetingListners(_meeting);
                },
              );

              if (meeting == null) {
                return Text("waiting to join meeting");
              }

              return Scaffold(
                floatingActionButton: MeetingActions(
                  localParticipant: localParticipant as Participant,
                  meeting: meeting as Meeting,
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                appBar: AppBar(title: Text(widget.title)),
                body: Container(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // Text("Active Seaker Id: $activeSpeakerId"),
                          // Text("Active Presenter Id: $activePresenterId"),
                          if (participants.length > 0)
                            Expanded(
                              child: ListRemoteParticipants(
                                participants: participants,
                              ),
                            )
                          else
                            Expanded(
                              child: Center(
                                child: Text("No participants."),
                              ),
                            ),
                        ],
                      ),
                      LocalParticipant(
                        localParticipant: localParticipant as Participant,
                        meeting: meeting as Meeting,
                      )
                    ],
                  ),
                ),
              );
            },
          )
        : Text("Initializing meeitng");
  }
}
