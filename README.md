# videosdk_rtc_flutter_sdk_example

This is VideoSDK RTC example code for flutter.

### Setting up authentication server and flutter app

1. Run the authentication server

   Follow instructions from [videosdk-rtc-nodejs-sdk-example](https://github.com/videosdk-live/videosdk-rtc-nodejs-sdk-example) to run the authentication server.

2. Clone the repo

   ```sh
   $ git clone https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example.git
   ```

3. Copy the `.env.example` file to `.env` file.

   ```sh
   $ cp .env.example .env
   ```

4. Update the api server url in the `.env` file that points to the authentication server.

   ```
   API_SERVER_HOST="http://localhost:9000"
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
