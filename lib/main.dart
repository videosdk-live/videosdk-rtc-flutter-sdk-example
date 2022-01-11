// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:videosdk/rtc.dart';

import 'ui/localParticipant/local_participant.dart';
import 'ui/meeting_actions.dart';
import 'ui/remoteParticipants/list_remote_participants.dart';
import 'ui/utils/navigator_key.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VideoSDK Flutter Example',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: const MyHomePage(title: 'VideoSDK Flutter Example'),
      navigatorKey: navigatorKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, Participant> participants = {};
  Participant? localParticipant;
  Meeting? meeting;

  String? activeSpeakerId;
  String? activePresenterId;

  String? meetingId;
  String? token;

  _MyHomePageState() {
    _fetchMeetingIdAndToken();
  }

  _handleMeetingListeners(Meeting meeting) {
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
      log("meeting speaker-changed => $_activeSpeakerId");
    });
    //
    meeting.on('presenter-changed', (_activePresenterId) {
      setState(() {
        activePresenterId = _activePresenterId;
      });
      log("meeting presenter-changed => $_activePresenterId");
    });
  }

  void _fetchMeetingIdAndToken() async {
    final String? _VIDEOSDK_API = dotenv.env['VIDEOSDK_API'];
    final String? _AUTH_TOKEN = dotenv.env['AUTH_TOKEN'];

    final Uri getMeetingIdUrl = Uri.parse('$_VIDEOSDK_API/meetings');

    final http.Response meetingIdResponse =
        await http.post(getMeetingIdUrl, headers: {
      "Authorization": "$_AUTH_TOKEN",
    });

    final _meetingId = json.decode(meetingIdResponse.body)['meetingId'];

    log("Meeting ID: $_meetingId");

    setState(() {
      token = _AUTH_TOKEN;
      meetingId = _meetingId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return meetingId != null && token != null
        ? MeetingBuilder(
            meetingId: meetingId as String,
            displayName: "Chintan Rajpara",
            token: token as String,
            micEnabled: true,
            webcamEnabled: true,
            builder: (_meeting) {
              _meeting.on(
                "meeting-joined",
                () {
                  setState(() {
                    localParticipant = _meeting.localParticipant;
                    meeting = _meeting;
                  });
                  _handleMeetingListeners(_meeting);
                },
              );

              if (meeting == null) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("waiting to join meeting"),
                      ],
                    ),
                  ),
                );
              }

              return Scaffold(
                floatingActionButton: MeetingActions(
                  localParticipant: localParticipant as Participant,
                  meeting: meeting as Meeting,
                  meetingId: meetingId as String,
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                appBar: AppBar(title: Text(widget.title)),
                body: Stack(
                  children: [
                    Column(
                      children: [
                        // Text("Active Speaker Id: $activeSpeakerId"),
                        // Text("Active Presenter Id: $activePresenterId"),
                        if (participants.isNotEmpty)
                          Expanded(
                            child: ListRemoteParticipants(
                              participants: participants,
                            ),
                          )
                        else
                          const Expanded(
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
              );
            },
          )
        : Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Initializing meeting"),
                ],
              ),
            ),
          );
  }
}
