# Video SDK for Flutter (Android and iOS)
[![Documentation](https://img.shields.io/badge/Read-Documentation-blue)](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/getting-started)
[![Firebase](https://img.shields.io/badge/Download%20Android-Firebase-green)](https://appdistribution.firebase.google.com/pub/i/0f3ac650239a944b)
[![TestFlight](https://img.shields.io/badge/Download%20iOS-TestFlight-blue)](https://testflight.apple.com/join/C1UOYbxh)
[![Discord](https://img.shields.io/discord/876774498798551130?label=Join%20on%20Discord)](https://discord.gg/bGZtAbwvab)
[![Register](https://img.shields.io/badge/Contact-Know%20More-blue)](https://app.videosdk.live/signup)

At Video SDK, we’re building tools to help companies create world-class collaborative products with capabilities of live audio/videos, compose cloud recordings/rtmp/hls and interaction APIs

## Demo App
Check out demo [here](https://videosdk.live/prebuilt/)

📲 Download the Sample iOS app here: https://testflight.apple.com/join/C1UOYbxh

📱 Download the Sample Android app here: https://appdistribution.firebase.google.com/pub/i/0f3ac650239a944b

## Steps to Integrate

### Prerequisites
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


### Step 1: Clone the sample project
Clone the repository to your local environment.
```js
$ git clone https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example.git
```

### Step 2: Copy the .env.example file to .env file.
Open your favorite code editor and copy `.env.example` to `.env` file.
```js 
$ cp .env.example .env
```

### Step 3: Modify .env file
Generate temporary token from [Video SDK Account](https://app.videosdk.live/signup).
```js title=".env"
AUTH_TOKEN = "TEMPORARY-TOKEN"
```

### Step 4: Install the dependecies
Install all the dependecies to run the project.
```js
flutter pub get
```

### Step 4: Run the sample app
Bingo, it's time to push the launch button. 
```js
flutter run
```

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

## Community
- [Discord](https://discord.gg/Gpmj6eCq5u) - To get involved with the Video SDK community, ask questions and share tips.
- [Twitter](https://twitter.com/video_sdk) - To receive updates, announcements, blog posts, and general Video SDK tips.
