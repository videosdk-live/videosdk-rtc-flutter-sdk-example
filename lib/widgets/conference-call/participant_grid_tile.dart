import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/widgets/common/stats/call_stats.dart';

class ParticipantGridTile extends StatefulWidget {
  final Participant participant;
  final bool isLocalParticipant;
  final String? activeSpeakerId;
  final String? quality;
  final int participantCount;
  final bool isPresenting;

  const ParticipantGridTile({
    Key? key,
    required this.participant,
    required this.quality,
    this.isLocalParticipant = false,
    required this.activeSpeakerId,
    required this.participantCount,
    required this.isPresenting,
  }) : super(key: key);

  @override
  State<ParticipantGridTile> createState() => _ParticipantGridTileState();
}

class _ParticipantGridTileState extends State<ParticipantGridTile> {
  Stream? videoStream;
  Stream? audioStream;

  @override
  void initState() {
    _initStreamListeners();
    super.initState();

    widget.participant.streams.forEach((key, Stream stream) {
      setState(() {
        if (stream.kind == 'video') {
          videoStream = stream;
          widget.participant.setQuality(widget.quality);
        } else if (stream.kind == 'audio') {
          audioStream = stream;
        }
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: ResponsiveValue<double>(context, conditionalValues: [
        Condition.equals(name: MOBILE, value: double.infinity),
        Condition.largerThan(
            name: MOBILE,
            value: widget.isPresenting
                ? double.infinity
                : kIsWeb && widget.participantCount == 1
                    ? MediaQuery.of(context).size.width / 1.5
                    : widget.participantCount > 2
                        ? widget.participantCount >= 5
                            ? 350
                            : 500
                        : double.infinity),
      ]).value!),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: black800,
        border: widget.activeSpeakerId != null &&
                widget.activeSpeakerId == widget.participant.id
            ? Border.all(color: Colors.blueAccent)
            : null,
      ),
      child: Stack(
        children: [
          videoStream != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RTCVideoView(
                    videoStream?.renderer as RTCVideoRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                )
              : Center(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: black500,
                    ),
                    child: Text(
                      widget.participant.displayName.characters.first
                          .toUpperCase(),
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
          if (audioStream == null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: black700,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.mic_off,
                    size: 15,
                  )),
            ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: black700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.participant.isLocal
                    ? "You"
                    : widget.participant.displayName)),
          ),
          Positioned(
              top: 4,
              left: 4,
              child: CallStats(participant: widget.participant)),
        ],
      ),
    );
  }

  _initStreamListeners() {
    widget.participant.on(Events.streamEnabled, (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video') {
          videoStream = _stream;
          widget.participant.setQuality(widget.quality);
        } else if (_stream.kind == 'audio') {
          audioStream = _stream;
        }
      });
    });

    widget.participant.on(Events.streamDisabled, (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
          videoStream = null;
        } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
          audioStream = null;
        }
      });
    });

    widget.participant.on(Events.streamPaused, (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
          videoStream = null;
        } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
          audioStream = _stream;
        }
      });
    });

    widget.participant.on(Events.streamResumed, (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
          videoStream = _stream;
          widget.participant.setQuality(widget.quality);
        } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
          audioStream = _stream;
        }
      });
    });
  }
}
