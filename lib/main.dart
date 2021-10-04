import 'ui/local_stream.dart';
import 'dart:convert';

import 'ui/list_remote_streams.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/rtc.dart';
import 'package:videosdk/meeting.dart';
import 'package:videosdk/participant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  print("loading dot env ");

  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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

  String? meetingId;
  String? token;

  _MyHomePageState() {
    this.localParticipant = null;
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

    meeting.on('meeting-left', () {
      setState(() {
        token = null;
        meetingId = null;
      });
    });
  }

  void _fetchMeetingIdAndToken() async {
    final API_SERVER_HOST = dotenv.env['API_SERVER_HOST'];

    final Uri get_token_url = Uri.parse('http://$API_SERVER_HOST/get-token');
    final http.Response tokenResponse = await http.get(get_token_url);

    final dynamic _token = json.decode(tokenResponse.body)['token'];

    final Uri get_meeting_id_url =
        Uri.parse('http://$API_SERVER_HOST/create-meeting/');

    final http.Response meetingIdResponse =
        await http.post(get_meeting_id_url, body: {"token": _token});

    final _meetingId = json.decode(meetingIdResponse.body)['meetingId'];

    print("_token => $_token _meetingId => $_meetingId");

    setState(() {
      token = _token;
      meetingId = _meetingId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      // body: Text("Meeitng View"),
      body: meetingId != null && token != null
          ? MeetingBuilder(
              meetingId: meetingId as String,
              displayName: "John Doe",
              token: token as String,
              micEnabled: true,
              webcamEnabled: true,
              builder: (Meeting _meeting) {
                print('builder _meeting => $_meeting');

                _meeting.on(
                  "meeting-joined",
                  () {
                    print('meeting-joined');

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

                return Container(
                  child: Column(
                    children: [
                      if (participants.length > 0)
                        ListRemoteStreams(
                          participants: participants,
                        )
                      else
                        Text("No Remote participants."),
                      if (localParticipant != null)
                        LocalStream(
                          localParticipant: localParticipant as Participant,
                          meeting: meeting as Meeting,
                        )
                      else
                        Text("Loading local participant.."),
                    ],
                  ),
                );
              },
            )
          : ElevatedButton(
              onPressed: _fetchMeetingIdAndToken,
              child: Text("Join"),
            ),
    );
  }
}
