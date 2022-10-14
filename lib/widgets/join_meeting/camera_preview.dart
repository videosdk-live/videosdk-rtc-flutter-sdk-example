import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class SelfCameraPreview extends StatefulWidget {
  const SelfCameraPreview({Key? key}) : super(key: key);

  @override
  State<SelfCameraPreview> createState() => _SelfCameraPreviewState();
}

class _SelfCameraPreviewState extends State<SelfCameraPreview> {
  // Camera Controller
  CameraController? cameraController;

  @override
  void initState() {
    // TODO: implement initState

    initCameraPreview();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (cameraController?.value.isInitialized ?? false)
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CameraPreview(cameraController!))
        : SizedBox.shrink();
  }

  void initCameraPreview() {
    // Get available cameras
    availableCameras().then((availableCameras) {
      // stores selected camera id
      int selectedCameraId = availableCameras.length > 1 ? 1 : 0;

      cameraController = CameraController(
        availableCameras[selectedCameraId],
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      log("Starting Camera");
      cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }).catchError((err) {
      log("Error: $err");
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    cameraController?.dispose();
    super.dispose();
  }
}
