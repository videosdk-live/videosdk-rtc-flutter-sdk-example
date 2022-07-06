import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:videosdk/rtc.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../utils/toast.dart';

class ParticipantTile extends StatefulWidget {
  final Participant participant;
  final bool isLocalParticipant;
  const ParticipantTile(
      {Key? key, required this.participant, this.isLocalParticipant = false})
      : super(key: key);

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;
  String? quality;

  bool shouldRenderVideo = true;

  GlobalKey _widgetKey = GlobalKey();

  @override
  void initState() {
    _initStreamListeners();
    super.initState();

    widget.participant.streams.forEach((key, Stream stream) {
      setState(() {
        if (stream.kind == 'video') {
          videoStream = stream;
          onViewPortChange();
        } else if (stream.kind == 'audio') {
          audioStream = stream;
        } else if (stream.kind == 'share') {
          shareStream = stream;
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
    return VisibilityDetector(
      key: Key("tile_${widget.participant.id}"),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0 && !shouldRenderVideo) {
          if (videoStream?.track.paused ?? true) {
            videoStream?.track.resume();
          }
          setState(() => shouldRenderVideo = true);
        } else if (visibilityInfo.visibleFraction == 0 && shouldRenderVideo) {
          videoStream?.track.pause();
          setState(() => shouldRenderVideo = false);
        }
      },
      child: Container(
        key: _widgetKey,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor.withOpacity(1),
          border: Border.all(
            color: Colors.white38,
          ),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Stack(
              children: [
                videoStream != null && shouldRenderVideo
                    ? RTCVideoView(
                        videoStream?.renderer as RTCVideoRenderer,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : const Center(
                        child: Icon(
                          Icons.person,
                          size: 180.0,
                          color: Color.fromARGB(140, 255, 255, 255),
                        ),
                      ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).backgroundColor.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white24,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        widget.participant.displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: audioStream != null
                            ? Theme.of(context).backgroundColor
                            : Colors.red,
                      ),
                      child: Icon(
                        audioStream != null ? Icons.mic : Icons.mic_off,
                        size: 16,
                      ),
                    ),
                    onTap: widget.isLocalParticipant
                        ? null
                        : () {
                            if (audioStream != null) {
                              widget.participant.disableMic();
                            } else {
                              toastMsg("Mic requested");
                              widget.participant.enableMic();
                            }
                          },
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: videoStream != null
                            ? Theme.of(context).backgroundColor
                            : Colors.red,
                      ),
                      child: videoStream != null
                          ? const Icon(
                              Icons.videocam,
                              size: 16,
                            )
                          : const Icon(
                              Icons.videocam_off,
                              size: 16,
                            ),
                    ),
                    onTap: widget.isLocalParticipant
                        ? null
                        : () {
                            if (videoStream != null) {
                              widget.participant.disableWebcam();
                            } else {
                              toastMsg("Webcam requested");
                              widget.participant.enableWebcam();
                            }
                          },
                  ),
                ),
                if (!widget.isLocalParticipant)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: const Icon(
                          Icons.logout,
                          size: 16,
                        ),
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text("Are you sure ?"),
                                  actions: [
                                    TextButton(
                                      child: const Text("Yes"),
                                      onPressed: () {
                                        widget.participant.remove();
                                        toastMsg("Participant removed");
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("No"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                ));
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  onViewPortChange() {
    try {
      final RenderBox renderBox =
          _widgetKey.currentContext?.findRenderObject() as RenderBox;
      _widgetKey.currentContext?.size;

      final Size size = renderBox.size;
      widget.participant.setViewPort(size.width, size.height);
    } catch (exception) {
      log("Unable to set Viewport $exception");
    }
  }

  _initStreamListeners() {
    widget.participant.on(Events.streamEnabled, (Stream _stream) {
      if (_stream.kind == 'video') {
        onViewPortChange();
      }
      setState(() {
        if (_stream.kind == 'video') {
          videoStream = _stream;
        } else if (_stream.kind == 'audio') {
          audioStream = _stream;
        } else if (_stream.kind == 'share') {
          shareStream = _stream;
        }
      });
    });

    widget.participant.on(Events.streamDisabled, (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
          videoStream = null;
        } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
          audioStream = null;
        } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
          shareStream = null;
        }
      });
    });

    widget.participant.on(Events.streamPaused, (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
          videoStream = _stream;
        } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
          audioStream = _stream;
        } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
          shareStream = _stream;
        }
      });
    });

    widget.participant.on(Events.streamResumed, (Stream _stream) {
      if (_stream.kind == 'video') {
        onViewPortChange();
      }
      setState(() {
        if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
          videoStream = _stream;
        } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
          audioStream = _stream;
        } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
          shareStream = _stream;
        }
      });
    });
  }
}
