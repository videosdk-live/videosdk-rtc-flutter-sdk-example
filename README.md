# 🚀 Video SDK for Flutter

[![Documentation](https://img.shields.io/badge/Read-Documentation-blue)](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/concept-and-architecture)
[![Firebase](https://img.shields.io/badge/Download%20Android-Firebase-green)](https://appdistribution.firebase.dev/i/80c2c6cc9fcb89b0)
[![TestFlight](https://img.shields.io/badge/Download%20iOS-TestFlight-blue)](https://testflight.apple.com/join/C1UOYbxh)
[![Discord](https://img.shields.io/discord/876774498798551130?label=Join%20on%20Discord)](https://discord.gg/bGZtAbwvab)
[![Register](https://img.shields.io/badge/Contact-Know%20More-blue)](https://app.videosdk.live/signup)

At Video SDK, we’re building tools to help companies create world-class collaborative products with capabilities for live audio/video, cloud recordings, RTMP/HLS streaming, and interaction APIs.

### 🥳 Get **10,000 minutes free** every month! **[Try it now!](https://app.videosdk.live/signup)**

## 📚 **Table of Contents**

- [🖥️ **Demo App**](#%EF%B8%8F-demo-app)
- [📱 **Video SDK Compatibility**](#-video-sdk-compatibility)
- [⚡ **Quick Setup**](#-quick-setup)
- [🔧 **Prerequisites**](#-prerequisites)
- [📦 **Running the Sample App**](#-running-the-sample-app)
- [🔥 **Meeting Features**](#-meeting-features)
- [🧠 **Key Concepts**](#-key-concepts)
- [🔑 **Token Generation**](#-token-generation)
- [🧩 **Project OverView**](#-project-overview)
- [📖 **Examples**](#-examples)
- [📝 **VideoSDK's Documentation**](#-documentation)
- [💬 **Join Our Community**](#-join-our-community)


## 🖥️ Demo App

📲 Download the sample iOS app here: https://testflight.apple.com/join/C1UOYbxh

📱 Download the sample Android app here: https://appdistribution.firebase.dev/i/80c2c6cc9fcb89b0


## 📱 Video SDK Compatibility

| Android | iOS | Web | MacOS | Windows | Safari |
|---------|-----|-----|-------|---------|--------|
| ✅       | ✅   | ✅   | ✅     | ✅       | ❌      |


## ⚡ Quick Setup

1. Sign up on [VideoSDK](https://app.videosdk.live/) to grab your API Key and Secret.
2. Familiarize yourself with [Token](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/authentication-and-tokens)

## 🛠 Prerequisites

- Flutter 2.0 or later
- Dart 3.3.0 or later
- A valid [Video SDK Account](https://app.videosdk.live/)

## 📦 Running the Sample App

Follow these steps to get the sample app up and running:

### 1. Clone the sample project

Clone the repository to your local environment.

```js
$ git clone https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example.git
```

### 2. Copy the `.env.example` file to `.env` file.

Open your favorite code editor and copy `.env.example` to `.env` file.

```js
$ cp .env.example .env
```

### 3. Modify `.env` file

Generate a temporary token from [Video SDK Account](https://app.videosdk.live/signup).

```js title=".env"
AUTH_TOKEN = "TEMPORARY-TOKEN";
```

### 4. Install the dependencies

Install all the dependencies to run the project.

```js
flutter pub get
```

### 4. Run the sample app

Bingo, it's time to push the launch button.

```js
flutter run
```

## 🔥 Meeting Features

Unlock a suite of powerful features to enhance your meetings:

| Feature                        | Documentation                                                                                                                | Description                                                                                                      |
|--------------------------------|------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| 📋 **Precall Setup**           | [Setup Precall](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/setup-call/precall)                   | Configure audio, video devices, and other settings before joining the meeting.                                              |
| 🤝 **Join Meeting**            | [Join Meeting](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/setup-call/join-meeting)                | Allows participants to join a meeting.                                                                 |
| 🚪 **Leave Meeting**            | [Leave Meeting](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/setup-call/leave-end-meeting)                | Allows participants to leave a meeting.                                                                 |
| 🎤 **Toggle Mic**         | [Mic Control](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/handling-media/mute-unmute-mic)          | Toggle the microphone on or off during a meeting.                                                                  |
| 📷 **Toggle Camera**           | [Camera Control](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/handling-media/on-off-camera)         | Turn the video camera on or off during a meeting.                                                                  |
| 🖥️ **Screen Share**            | [Screen Share](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/handling-media/screen-share)          | Share your screen with other participants during the call.                                                      |
| 🔊 **Change Audio Output**     | [Switch Audio Output](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/handling-media/change-audio-output-device) | Select an output device for audio during a meeting.                                                                |
| 🔌 **Change Video Output**     | [Switch Video Output](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/handling-media/change-video-input-device) | Select an output device for audio during a meeting.                                                                |
| ⚙️ **Optimize Audio Track**         | [Audio Track Optimization](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/render-media/optimize-audio-track)                                       | Enhance the quality and performance of media tracks.                                                            |
| ⚙️ **Optimize Video Track**         | [Video Track Optimization](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/render-media/optimize-video-track)                                       | Enhance the quality and performance of media tracks.                                                            |
| 🖼️ **Virtual Background**        | [Virtual Background](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/render-media/virtual-background)                                       | Add a virtual background or blur effect to your video during the call.                                                            |
| 💬 **Chat**                    | [In-Meeting Chat](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/collaboration-in-meeting/pubsub)      | Exchange messages with participants through a Publish-Subscribe mechanism.                                                   |
| 📝 **Whiteboard**              | [Whiteboard](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/collaboration-in-meeting/whiteboard)      | Collaborate visually by drawing and annotating on a shared whiteboard.                                           |
| 📼 **Recording**               | [Recording](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/recording/Overview)                | Record the meeting for future reference.                                                                        |
| 📡 **RTMP Livestream**         | [RTMP Livestream](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/live-streaming/rtmp-livestream)        | Stream the meeting live to platforms like YouTube or Facebook.                                                  |
| 📝 **Real-time Transcription**           | [Real-time Transcription](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/transcription-and-summary/realtime-transcribe-meeting) | Generate real-time transcriptions of the meeting.                                                               |
| 🔇 **Toggle Remote Media**     | [Remote Media Control](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/control-remote-participant/remote-participant-media) | Control the microphone or camera of remote participants.                                                        |
| 🚫 **Mute All Participants**   | [Mute All](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/control-remote-participant/mute-all-participants) | Mute all participants simultaneously during the call.                                                           |
| 🗑️ **Remove Participant**      | [Remove Participant](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/control-remote-participant/remove-participant) | Eject a participant from the meeting.  |

## 🧠 Key Concepts

Understand the core components of our SDK:

- `Meeting` - A Meeting represents Real-time audio and video communication.

  **` Note: Don't confuse the terms Room and Meeting; both mean the same thing 😃`**

- `Sessions` - A particular duration you spend in a given meeting is referred as a session, you can have multiple sessions of a specific meetingId.
- `Participant` - A participant refers to anyone attending the meeting session. The `local participant` represents yourself (You), while all other attendees are considered `remote participants`.
- `Stream` - A stream refers to video or audio media content that is published by either the `local participant` or `remote participants`.


## 🔐 Token Generation

The token is used to create and validate a meeting using API and also initialize a meeting.

🛠️ `Development Environment`:

- You may use a temporary token for development. To create a temporary token, go to VideoSDK's [dashboard](https://app.videosdk.live/api-keys) .

🌐 `Production Environment`:

- You must set up an authentication server to authorize users for production. To set up an authentication server, please take a look at our official example repositories. [videosdk-rtc-api-server-examples](https://github.com/videosdk-live/videosdk-rtc-api-server-examples)


## 🧩 Project Overview

### App Behaviour with Different Meeting Types

- **One-to-One meeting** - The One-to-One meeting allows 2 participants to join a meeting in the app.

- **Group Meeting** - The Group meeting allows any number of participants to join a meeting in the app with a maximum of 6 participants on screen.

## 🏗️ Project Structure

- We have separated screens and widgets in the following folder structure:
  - `one-to-one` - It includes all files related to the OneToOne meeting.
  - `common` - It includes all the files used in both meeting types (OneToOne and Group calls).
  - `conference-call` - It includes all files related to the conference call.

### 1. Pre-Call Setup on Join Screen

- **[lib/widgets/common/pre_call/selectAudioDevice.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/common/pre_call/selectAudioDevice.dart)**  : This file implements the `SelectAudioDevice` widget, which allows users to select an audio output device.

- **[lib/widgets/common/pre_call/selectVideoDevice.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/lib/widgets/common/pre_call/selectVideoDevice.dart)** : This file provides the `SelectVideoDevice` widget for choosing a video input device (camera).

- **[lib/widgets/common/pre_call/dropdowns_Web.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/screens/common/dropdowns_Web.dart)** : This file defines the `DropdownsWebWidget`, a stateful widget that manages dropdown menus for selecting video and audio devices in a web interface.

### 2. Create or Join Meeting

- **[lib/utils/api.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/utils/api.dart)** : This file handles the API interactions, including fetching a token, creating a meeting, validating a meeting, and fetching session data.

- **[lib/widgets/common/joining/join_view.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/common/joining/join_view.dart)** : This file defines the `JoinView` widget, which provides the user interface for joining a meeting.

- **[lib/screens/common/join_screen.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/screens/common/join_screen.dart)** : 
  - This file implements the `JoinScreen` widget, the main screen for joining or creating meetings.
  - It includes logic for handling device permissions, displaying the camera preview, and navigating to different meeting screens (one-to-one or group) after joining or creating a meeting.

- **[lib/widgets/common/joining_details/joining_details.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/common/joining_details/joining_details.dart)** : 
  - This file defines the `JoiningDetails` widget, where users input meeting details like the meeting ID and their display name.
  - It includes a dropdown for selecting the meeting type (e.g., "One to One" or "Group Call"), and text fields for the meeting ID (when joining) and display name.

### 3. Waiting Screen

- **[lib/widgets/common/joining/waiting_to_join.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/common/joining/waiting_to_join.dart)** : The `waiting_to_join.dart` file defines a basic UI screen that displays a loading animation and a message to notify users that a room is being set up as they wait.

### 4. Meeting App Bar for Mobile

- **[lib/widgets/common/app_bar/meeting_appbar.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/common/app_bar/meeting_appbar.dart)** : This file defines the `MeetingAppBar` widget, which shows details like the meeting ID, recording status, and the session's elapsed time.

### 5. Meeting Bottom Bar for Mobile

- **[lib/widgets/common/meeting_controls/meeting_action_bar.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/common/meeting_controls/meeting_action_bar.dart)** : This file defines the `MeetingActionBar` widget, which provides essential meeting controls at the bottom of the screen. Its main components include meeting controls like ending/ leaving a call, toggling the microphone and camera, and accessing chat. It also provides options for recording, screen sharing, and viewing the participant list.

### 6. Meeting App Bar for Web

- **[lib/widgets/common/app_bar/web_meeting_appbar.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/common/app_bar/web_meeting_appbar.dart)** : This file defines the `WebMeetingAppBar` widget, serving as the top control bar for a web meeting interface. It features a meeting ID display with a copy button, recording indicator, microphone and camera controls with device options, screen sharing control, chat and participant list buttons, and an option to leave or end the meeting for all participants.

### 7. Chat

- **[lib/widgets/common/chat.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/common/chat/chat_view.dart)** : This file defines the `ChatView` widget. It displays incoming messages and enables users to send new messages.

### 8. Participant List

- **[lib/widgets/common/participant/participant_list_item.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/common/participant/participant_list_item.dart)** and **[lib/widgets/common/participant/participant_list.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/common/participant/participant_list.dart)** : Displays the list of participants present in the meeting.

### 9. Participant View
 
### OneToOne Call

- **[lib/screens/one-to-one/one_to_one_meeting_screen.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/screens/one-to-one/one_to_one_meeting_screen.dart)** : It contains the complete layout for one to one meeting.

- **[lib/widgets/one-to-one/one_to_one_meeting_container.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/one-to-one/one_to_one_meeting_container.dart)** : The `OneToOneMeetingContainer` widget manages the display of local and remote participant streams in a one-on-one meeting, dynamically adjusting for video, audio, and screen share streams with responsive layout support.

- **[lib/widgets/one-to-one/participant_view.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/one-to-one/participant_view.dart)** : It is used to display the individual stream of the participant.

### Conference Call

- **[lib/widgets/conference-call/conference_participant_grid.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/conference-call/conference_participant_grid.dart)** : The `ConferenceParticipantGrid` widget organizes and displays participants in a grid layout.

- **[lib/widgets/conference-call/participant_grid_tile.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/conference-call/participant_grid_tile.dart)** : The `ParticipantGridTile` widget displays single participant which is displayed in the grid.

- **[lib/widgets/conference-call/manage_grid.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/conference-call/manage_grid.dart)** : The `ManageGrid` class organize participants into grid layouts for different device types (mobile, tablet, desktop) during a conference, adjusting the number of rows and columns based on the participant count and presentation mode.

- **[lib/widgets/conference-call/conference_screenshare_view.dart](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example/blob/main/lib/widgets/conference-call/conference_screenshare_view.dart)** : The `ConferenseScreenShareView` widget handles the display of a screen share stream during a meeting.

## 📖 Examples

- [**Prebuilt Example**](https://github.com/videosdk-live/videosdk-rtc-prebuilt-examples)
- [**JavaScript SDK Example**](https://github.com/videosdk-live/videosdk-rtc-javascript-sdk-example)
- [**React SDK Example**](https://github.com/videosdk-live/videosdk-rtc-react-sdk-example.git)
- [**React Native SDK Example**](https://github.com/videosdk-live/videosdk-rtc-react-native-sdk-example)
- [**Android Java SDK Example**](https://github.com/videosdk-live/videosdk-rtc-android-java-sdk-example)
- [**Android Kotlin SDK Example**](https://github.com/videosdk-live/videosdk-rtc-android-kotlin-sdk-example)
- [**iOS SDK Example**](https://github.com/videosdk-live/videosdk-rtc-ios-sdk-example)


## 📝 Documentation

Explore more and start building with our [**Documentation**](https://docs.videosdk.live/)

## 🤝 Join Our Community

- **[Discord](https://discord.gg/Gpmj6eCq5u)**: Engage with the Video SDK community, ask questions, and share insights.
- **[X](https://x.com/video_sdk)**: Stay updated with the latest news, updates, and tips from Video SDK.
