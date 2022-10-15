# Video SDK for Flutter (Android and iOS)

[![Documentation](https://img.shields.io/badge/Read-Documentation-blue)](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/getting-started)
[![Firebase](https://img.shields.io/badge/Download%20Android-Firebase-green)](https://appdistribution.firebase.google.com/pub/i/0f3ac650239a944b)
[![TestFlight](https://img.shields.io/badge/Download%20iOS-TestFlight-blue)](https://testflight.apple.com/join/C1UOYbxh)
[![Discord](https://img.shields.io/discord/876774498798551130?label=Join%20on%20Discord)](https://discord.gg/bGZtAbwvab)
[![Register](https://img.shields.io/badge/Contact-Know%20More-blue)](https://app.videosdk.live/signup)

At Video SDK, we’re building tools to help companies create world-class collaborative products with capabilities of live audio/videos, compose cloud recordings/rtmp/hls and interaction APIs

## Demo App

📲 Download the sample iOS app here: https://testflight.apple.com/join/C1UOYbxh

📱 Download the sample Android app here: https://appdistribution.firebase.google.com/pub/i/0f3ac650239a944b

## Features

- [x] Real-time video and audio conferencing
- [x] Enable/disable camera
- [x] Mute/unmute mic
- [x] Switch between front and back camera
- [x] Change audio device
- [x] Screen share
- [x] Chat
- [x] Recording

<br/>

## Setup Guide

- Sign up on [VideoSDK](https://app.videosdk.live/) and visit [API Keys](https://app.videosdk.live/api-keys) section to get your API key and Secret key.

- Get familiarized with [API key and Secret key](https://docs.videosdk.live/android/guide/video-and-audio-calling-api-sdk/signup-and-create-api)

- Get familiarized with [Token](https://docs.videosdk.live/android/guide/video-and-audio-calling-api-sdk/server-setup)

<br/>

## Prerequisites

- If your target platform is iOS, your development environment must meet the following requirements:
  - Flutter 2.0 or later
  - Dart 2.12.0 or later
  - macOS
  - Xcode (Latest version recommended)
- If your target platform is Android, your development environment must meet the following requirements:
  - Flutter 2.0 or later
  - Dart 2.12.0 or later
  - macOS or Windows
  - Android Studio (Latest version recommended)
- If your target platform is iOS, you need a real iOS device.
- If your target platform is Android, you need an Android simulator or a real Android device.
- Valid Video SDK [Account](https://app.videosdk.live/)

<br/>

## Run the Sample App

### 1. Clone the sample project

Clone the repository to your local environment.

```js
$ git clone https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example.git
```

### 2. Copy the .env.example file to .env file.

Open your favorite code editor and copy `.env.example` to `.env` file.

```js
$ cp .env.example .env
```

### 3. Modify .env file

Generate temporary token from [Video SDK Account](https://app.videosdk.live/signup).

```js title=".env"
AUTH_TOKEN = "TEMPORARY-TOKEN";
```

### 4. Install the dependecies

Install all the dependecies to run the project.

```js
flutter pub get
```

### 4. Run the sample app

Bingo, it's time to push the launch button.

```js
flutter run
```

<br/>

## Key Concepts

- `Meeting` - A Meeting represents Real time audio and video communication.

  **`Note : Don't confuse with Room and Meeting keyword, both are same thing 😃`**

- `Sessions` - A particular duration you spend in a given meeting is a referred as session, you can have multiple session of a particular meetingId.
- `Participant` - Participant represents someone who is attending the meeting's session, `local partcipant` represents self (You), for this self, other participants are `remote participants`.
- `Stream` - Stream means video or audio media content that is either published by `local participant` or `remote participants`.

<br/>

## Android Permission

Add all the following permissions to AndroidManifest.xml file.

```
    <uses-feature android:name="android.hardware.camera" />
    <uses-feature android:name="android.hardware.camera.autofocus" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />

    <!-- Needed to communicate with already-paired Bluetooth devices. (Legacy up to Android 11) -->
    <uses-permission
        android:name="android.permission.BLUETOOTH"
        android:maxSdkVersion="30" />
    <uses-permission
        android:name="android.permission.BLUETOOTH_ADMIN"
        android:maxSdkVersion="30" />

    <!-- Needed to communicate with already-paired Bluetooth devices. (Android 12 upwards)-->
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

```

## iOS Permission

Add the following entry to your Info.plist file, located at `<project root>/ios/Runner/Info.plist`:

```
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) Camera Usage!</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) Microphone Usage!</string>
```

## iOS Screen share Setup

Please refer to this documentation guide to [setup screenshare for iOS](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/extras/flutter-ios-screen-share)

<br/>

## Token Generation

Token is used to create and validate a meeting using API and also initialise a meeting.

🛠️ `Development Environment`:

- For development, you can use temporary token. Visit VideoSDK [dashboard](https://app.videosdk.live/api-keys) to generate temporary token.

🌐 `Production Environment`:

- For production, you have to set up an authentication server to authorize users. Follow our official example repositories to setup authentication server, [videosdk-rtc-api-server-examples](https://github.com/videosdk-live/videosdk-rtc-api-server-examples)

> **Note** :
>
> The expiry of development environment token lasts 7 days only.

<br/>

## API: Create and Validate meeting

- `create meeting` - Please refer this [documentation](https://docs.videosdk.live/api-reference/realtime-communication/create-room) to create meeting.
- `validate meeting`- Please refer this [documentation](https://docs.videosdk.live/api-reference/realtime-communication/validate-room) to validate the meetingId.

<br/>

## [Initialize a Meeting](https://docs.videosdk.live/flutter/api/sdk-reference/videosdk-class/methods#createroom)

- You can initialize the meeting using `createRoom()` method. `createRoom()` will generate a new `Room` object and the initiated meeting will be returned.

```js
  Room room = VideoSDK.createRoom(
        roomId: "abcd-efgh-ijkl",
        token: "YOUR TOKEN",
        displayName: "GUEST",
        micEnabled: true,
        camEnabled: true,
        maxResolution: 'hd',
        defaultCameraIndex: 1,
        notification: const NotificationInfo(
          title: "Video SDK",
          message: "Video SDK is sharing screen in the meeting",
          icon: "notification_share", // drawable icon name
        ),
      );
```

<br/>

## [Mute/Unmute Local Audio](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/features/mic-controls)

```js
// unmute mic
room.unmuteMic();

// mute mic
room.muteMic();
```

<br/>

## [Change Audio Device](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/features/switch-audio-output)

- The `meeting.getAudioOutputDevices()` function allows a participant to list all of the attached audio devices (e.g., Bluetooth and Earphone).

```js
 // get connected audio devices
 List<MediaDeviceInfo> outputDevice = room.getAudioOutputDevices()
```

- Local participant can change the audio device using `switchAudioOutput(MediaDeviceInfo device)` method of `Room` class.

```js
// change mic
room.switchAudioOutput(mediaDeviceInfo);
```

- Please consult our documentation [Change Audio Device](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/features/switch-audio-output) for more infromation.

<br/>

## [Enable/Disable Local Webcam](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/features/camera-controls)

```js
// enable webcam
room.enableCam();

// disable webcam
room.disableCam();
```

<br/>

## [Switch Local Webcam](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/features/camera-controls)

```js
// switch webcam
room.changeCam(deviceId);
```

<br/>

## [Chat](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/features/pubsub)

- The chat feature allows participants to send and receive messages about specific topics to which they have subscribed.

```js
// publish
room.pubSub.publish(String topic,String message, PubSubPublishOptions pubSubPublishoptions);

// pubSubPublishoptions is an object of PubSubPublishOptions, which provides an option, such as persist, which persists message history for upcoming participants.


//subscribe
PubSubMessages pubSubMessageList = room.pubSub.subscribe(String topic, Function(PubSubMessage) messageHandler)


//unsubscribe
room.pubSub.unsubscribe(topic, Function(PubSubMessage) messageHandler);


// Message Handler
void messageHandler(msg){
  // Do something
  print("New message received: $msg");
}
```

<br/>

## [Leave or End Meeting](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/features/leave-end-room)

```js
// Only one participant will leave/exit the meeting; the rest of the participants will remain.
room.leave();

// The meeting will come to an end for each and every participant. So, use this function in accordance with your requirements.
room.end();
```

<br/>

## [Listen for Room Events](https://docs.videosdk.live/flutter/api/sdk-reference/room-class/events)

By registering callback handlers, VideoSDK sends callbacks to the client app whenever there is a change or update in the meeting after a user joins.

```js
    room.on(
      Events.roomJoined,
      () {
        // This event will be emitted when a localParticipant(you) successfully joined the meeting.
      },
    );

    room.on(Events.roomLeft, (String? errorMsg) {
      // This event will be emitted when a localParticipant(you) left the meeting.
      // [errorMsg]: It will have the message if meeting was left due to some error like Network problem
    });

    room.on(Events.recordingStarted, () {
      // This event will be emitted when recording of the meeting is started.
    });

    room.on(Events.recordingStopped, () {
      // This event will be emitted when recording of the meeting is stopped.
    });

    room.on(Events.presenterChanged, (_activePresenterId) {
      // This event will be emitted when any participant starts or stops screen sharing.
      // [participantId]: Id of participant who shares the screen.
    });

    room.on(Events.speakerChanged, (_activeSpeakerId) {
      // This event will be emitted when a active speaker changed.
      // [participantId] : Id of active speaker
    });

    room.on(Events.participantJoined, (Participant participant) {
      // This event will be emitted when a new participant joined the meeting.
      // [participant]: new participant who joined the meeting
    });

    room.on(Events.participantLeft, (participantId) => {
      // This event will be emitted when a joined participant left the meeting.
      // [participantId]: id of participant who left the meeting
    });

```

<br/>

## [Listen for Participant Events](https://docs.videosdk.live/flutter/api/sdk-reference/participant-class/events)

By registering callback handlers, VideoSDK sends callbacks to the client app whenever a participant's video, audio, or screen share stream is enabled or disabled.

```js
  participant.on(Events.streamEnabled, (Stream _stream) {
    // This event will be triggered whenever a participant's video, audio or screen share stream is enabled.
  });

  participant.on(Events.stereamDisabled, (Stream _stream) {
    // This event will be triggered whenever a participant's video, audio or screen share stream is disabled.
  });

```

If you want to learn more about the SDK, read the Complete Documentation of [Flutter VideoSDK](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/getting-started)

<br/>

## Project Description

<br/>

> **Note :**
>
> - **master** branch: Better UI with One-to-One call experience.
> - **v1-code-sample** branch: Simple UI with Group call experience.

<br/>

### App Behaviour with Different Meeting Types

- **One-to-One meeting** - The One-to-One meeting allows 2 participants to join a meeting in the app.

- **Group Meeting** - 🔜 **_COMING SOON_**

<br/>

## Project Structure

- We have seprated screens and widget in following folder structure:
  - `one-to-one` - It includes all files related to OneToOne meeting.
  - `common` - It inclues all the files that are used in both meeting type (OneToOne and Group calls).

### Common Content

**1. Create or join Meeting**

- `join_screen.dart`: It shows the user with the option to create or join a meeting and to initiate webcam and mic status.

  - `api.dart` : It incldes all the API calls for create and validate meeting.

  - `joining_details.dart`: This widget allows user to enter the meetingId and name for the meeting.

  - If `Join Meeting` is clicked, it will show following:

    - `EditText for ParticipantName` - This edit text will contain name of the participant.
    - `EditText for MeetingId` - This edit text will contain the meeting Id that you want to join.
    - `Join Meeting Button` - This button will call api for join meeting with meetingId that you

  - If `Create Meeting` is clicked, it will show following:
    - `EditText for ParticipantName` - This edit text will contain name of the participant.
    - `Join Meeting Button` - This button will call api for join meeting with meetingId that you

  <p align="center">
  <img width="230" height="450" src="https://www.linkpicture.com/q/img_CreateOrJoinFragment.jpg"/>
  </p>

**2. PartcipantList**

- `participant_list.dart` and `participant_list_item.dart` files are used to show Participant list.
  <p align="center">
  <img width="250" height="450" src="https://www.linkpicture.com/q/img_participantList.jpg"/>
  </p>

**3. Meeting Actions**

- Meeting actions are present in the `meeting_action_bar.dart`

  - **MoreOptions**:
    <p align="center">
    <img width="350" height="250" src="https://www.linkpicture.com/q/img_MoreOptionList.jpg"/>
    </p>
  - **AudioDeviceList**:
    <p align="center">
    <img width="350" height="250" src="https://www.linkpicture.com/q/img_AudioDeviceList.jpg"/>
    </p>
  - **LeaveOrEndDialog**:
    <p align="center">
    <img width="350" height="250" src="https://www.linkpicture.com/q/img_LeaveorEndDialog.jpg"/>
    </p>

**4. Meeting Top Bar**

- `meeting_appbar.dart`: It contains the meeting timer, switch camera option and recording indicatior.

**5. Chat**

- `chat_screen.dart`: It contains the chat screen made using PubSub.

### One-to-one

- `one_to_one_meeting_screen.dart`: It contains the complete layout for one to one meeting.

- `one_to_one_meeting_container.dart`: It contains the logic to render the participants in the miniview and large view.

- `participant_view.dart`: It is used to display the individual stream of the participant.

## Examples

- [Prebuilt SDK Examples](https://github.com/videosdk-live/videosdk-rtc-prebuilt-examples)
- [JavaScript SDK Example](https://github.com/videosdk-live/videosdk-rtc-javascript-sdk-example)
- [React JS SDK Example](https://github.com/videosdk-live/videosdk-rtc-react-sdk-example)
- [React Native SDK Example](https://github.com/videosdk-live/videosdk-rtc-react-native-sdk-example)
- [Flutter SDK Example](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example)
- [Android SDK Example](https://github.com/videosdk-live/videosdk-rtc-android-java-sdk-example)
- [iOS SDK Example](https://github.com/videosdk-live/videosdk-rtc-ios-sdk-example)

## Documentation

[Read the documentation](https://docs.videosdk.live/) to start using Video SDK.

<br/>

## Community

- [Discord](https://discord.gg/Gpmj6eCq5u) - To get involved with the Video SDK community, ask questions and share tips.
- [Twitter](https://twitter.com/video_sdk) - To receive updates, announcements, blog posts, and general Video SDK tips.
