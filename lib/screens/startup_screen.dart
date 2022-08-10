// ignore_for_file: non_constant_identifier_names, dead_code

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../constants/colors.dart';
import '../utils/spacer.dart';
import '../utils/toast.dart';
import 'join_screen.dart';
import 'meeting_screen.dart';

// Startup Screen
class StartupScreen extends StatefulWidget {
  const StartupScreen({Key? key}) : super(key: key);

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  String _token = "";
  String _meetingID = "";

  final ButtonStyle _buttonStyle = TextButton.styleFrom(
    primary: Colors.white,
    backgroundColor: primaryColor,
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await fetchToken();
      setState(() => _token = token);
    });
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VideoSDK RTC"),
      ),
      backgroundColor: secondaryColor,
      body: SafeArea(
        child: _token.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    HorizontalSpacer(12),
                    Text("Initialization"),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: _buttonStyle,
                    onPressed: onCreateMeetingButtonPressed,
                    child: const Text("CREATE MEETING"),
                  ),
                  const VerticalSpacer(20),
                  const Text(
                    "OR",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const VerticalSpacer(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      onChanged: (meetingID) => _meetingID = meetingID,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        fillColor: Theme.of(context).primaryColor,
                        labelText: "Enter Meeting ID",
                        hintText: "Meeting ID",
                        prefixIcon: const Icon(
                          Icons.keyboard,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const VerticalSpacer(20),
                  TextButton(
                    onPressed: onJoinMeetingButtonPressed,
                    style: _buttonStyle,
                    child: const Text("JOIN MEETING"),
                  )
                ],
              ),
      ),
    );
  }

  Future<String> fetchToken() async {
    if (!dotenv.isInitialized) {
      // Load Environment variables
      await dotenv.load(fileName: ".env");
    }
    final String? _AUTH_URL = dotenv.env['AUTH_URL'];
    String? _AUTH_TOKEN = dotenv.env['AUTH_TOKEN'];

    if ((_AUTH_TOKEN?.isEmpty ?? true) && (_AUTH_URL?.isEmpty ?? true)) {
      toastMsg("Please set the environment variables");
      throw Exception("Either AUTH_TOKEN or AUTH_URL is not set in .env file");
      return "";
    }

    if ((_AUTH_TOKEN?.isNotEmpty ?? false) &&
        (_AUTH_URL?.isNotEmpty ?? false)) {
      toastMsg("Please set only one environment variable");
      throw Exception("Either AUTH_TOKEN or AUTH_URL can be set in .env file");
      return "";
    }

    if (_AUTH_URL?.isNotEmpty ?? false) {
      final Uri getTokenUrl = Uri.parse('$_AUTH_URL/get-token');
      final http.Response tokenResponse = await http.get(getTokenUrl);
      _AUTH_TOKEN = json.decode(tokenResponse.body)['token'];
    }

    // log("Auth Token: $_AUTH_TOKEN");

    return _AUTH_TOKEN ?? "";
  }

  Future<void> onCreateMeetingButtonPressed() async {
    final String? _VIDEOSDK_API_ENDPOINT = dotenv.env['VIDEOSDK_API_ENDPOINT'];

    final Uri getMeetingIdUrl = Uri.parse('$_VIDEOSDK_API_ENDPOINT/meetings');
    final http.Response meetingIdResponse =
        await http.post(getMeetingIdUrl, headers: {
      "Authorization": _token,
    });

    _meetingID = json.decode(meetingIdResponse.body)['meetingId'];

    log("Meeting ID: $_meetingID");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingScreen(
          token: _token,
          meetingId: _meetingID,
          displayName: "VideoSDK User",
        ),
      ),
    );
  }

  Future<void> onJoinMeetingButtonPressed() async {
    if (_meetingID.isEmpty) {
      toastMsg("Please, Enter Valid Meeting ID");
      return;
    }

    final String? _VIDEOSDK_API_ENDPOINT = dotenv.env['VIDEOSDK_API_ENDPOINT'];

    final Uri validateMeetingUrl =
        Uri.parse('$_VIDEOSDK_API_ENDPOINT/meetings/$_meetingID');
    final http.Response validateMeetingResponse =
        await http.post(validateMeetingUrl, headers: {
      "Authorization": _token,
    });

    if (validateMeetingResponse.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinScreen(
            meetingId: _meetingID,
            token: _token,
          ),
        ),
      );
    } else {
      toastMsg("Invalid Meeting ID");
    }
  }
}
