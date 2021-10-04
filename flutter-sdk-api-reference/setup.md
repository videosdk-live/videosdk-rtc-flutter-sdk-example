---
title: Installation Steps for RTC Flutter SDK
hide_title: false
hide_table_of_contents: false
description: RTC Flutter SDK provides client for almost all Android and IOS devices. it takes less amount of cpu and memory.
sidebar_label: Setup
pagination_label: Setup
keywords:
  - RTC FLUTTER
  - FLUTTER SDK
  - DART SDK
image: img/videosdklive-thumbnail.jpg
sidebar_position: 1
slug: setup
---

# Setup

## Setting up Flutter SDK

Flutter SDK is client for real-time communication for android and ios devices. It inherits the same terminology as all other SDKs does.

## Minimum OS/SDK versions

### Android: minSdkVersion >= 21

<!-- ### iOS: > 11 -->

## Use this package as a library

### Step 1: Add this package in your flutter project

#### Run this command:

```
flutter pub add videosdk
```

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```
dependencies:
  videosdk: ^0.0.4
```

Alternatively, your editor might support or flutter pub get. Check the docs for your editor to learn more.

### Step 2: Import it

Now in your Dart code, you can use:

```
import 'package:videosdk/meeting.dart';
import 'package:videosdk/meeting_builder.dart';
import 'package:videosdk/participant.dart';
import 'package:videosdk/rtc.dart';
import 'package:videosdk/stream.dart';
```

---

# Next step

[Meeting Builder Widget](meeting-builder-widget.md)

# Complete API References

- [Setup](setup.md)
- [Meeting Builder Widget](meeting-builder-widget.md)
- [Meeting Class](meeting-class.md)
- [Participant Class](participant-class.md)
- [Stream Class](stream-class.md)
