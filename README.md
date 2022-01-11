# videosdk_rtc_flutter_sdk_example

This is VideoSDK RTC example code for flutter.

### Setting up flutter app

1. There are 2 options
   Option 1: Get Auth Token from [VideoSDK Dashboard](https://app.videosdk.live/dashboard)
   Option 2: Setting up Auth Server [Instructions](https://github.com/videosdk-live/videosdk-rtc-nodejs-sdk-example)

2. Clone the repo

   ```sh
   $ git clone https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example.git
   ```

3. Copy the `.env.example` file to `.env` file.

   ```sh
   $ cp .env.example .env
   ```

4. Either update `AUTH_TOKEN` or `AUTH_URL` in the `.env` file.

   ```
   AUTH_TOKEN=#YOUR_GENERATED_TOKEN
   ```

   OR

   ```
   AUTH_URL=#YOUR_AUTH_SERVER_URL
   ```

5. Install pub

   ```sh
   $ flutter pub get
   ```

6. Run the app

   ```sh
   $ flutter run
   ```

## For more information please visit:

### [Guide](https://docs.videosdk.live/docs/guide/video-and-audio-calling-api-sdk/flutter-sdk)

### [API Reference](https://docs.videosdk.live/docs/realtime-communication/sdk-reference/flutter-sdk/setup)

Related

- [Video SDK RTC React Example](https://github.com/videosdk-live/videosdk-rtc-react-sdk-example)
- [Video SDK RTC React Native Example](https://github.com/videosdk-live/videosdk-rtc-react-native-sdk-example)
- [Video SDK RTC Flutter Example](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example)
- [Video SDK RTC Android Example](https://github.com/videosdk-live/videosdk-rtc-android-java-sdk-example)
- [Video SDK RTC iOS Example](https://github.com/videosdk-live/videosdk-rtc-ios-sdk-example)
