import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class RecordingIndicator extends StatefulWidget {
  final String recordingState;
  const RecordingIndicator({Key? key, required this.recordingState})
      : super(key: key);

  @override
  State<RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RecordingIndicator oldWidget) {
    if (widget.recordingState == "STARTED" ||
        widget.recordingState == "STOPPED") {
      _animationController.stop();
      _animationController.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: _animationController,
        child: Lottie.asset('assets/recording_lottie.json', height: 35));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
