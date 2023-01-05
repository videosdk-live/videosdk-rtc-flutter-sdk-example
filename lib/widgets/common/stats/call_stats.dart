import 'dart:async';
import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'package:videosdk_flutter_example/widgets/common/stats/call_stats_bottom_sheet.dart';

class CallStats extends StatefulWidget {
  final Participant participant;

  const CallStats({Key? key, required this.participant}) : super(key: key);

  @override
  State<CallStats> createState() => _CallStatsState();
}

class _CallStatsState extends State<CallStats> {
  Timer? statsTimer;
  bool showFullStats = false;
  int? score;

  @override
  void initState() {
    statsTimer = Timer.periodic(const Duration(seconds: 1), updateStats);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: score != null && !showFullStats
          ? GestureDetector(
              onTap: () {
                setState(() {
                  showFullStats = !showFullStats;
                });
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    barrierColor: Colors.transparent,
                    context: context,
                    builder: (_) {
                      return CallStatsBottomSheet(
                          participant: widget.participant);
                    }).whenComplete(() => {
                      setState(() {
                        showFullStats = !showFullStats;
                      })
                    });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: score! > 7
                      ? green
                      : score! > 4
                          ? yellow
                          : red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.network_cell),
              ),
            )
          : null,
    );
  }

  void updateStats(Timer timer) {
    var _audioStats = widget.participant.getAudioStats();
    var _videoStats = widget.participant.getVideoStats();
    var vStats;
    _videoStats?.forEach((stat) {
      if (vStats == null) {
        vStats = stat;
      } else {
        if (stat['size']['width'] != "null" && stat['size']['width'] != null) {
          if (stat['size']['width'] > vStats['size']['width']) {
            vStats = stat;
          }
        }
      }
    });
    var stats = {};
    if (_audioStats != null) {
      stats = _audioStats[0];
    } else if (vStats != null) {
      stats = vStats;
    }

    double packetLossPercent =
        (stats['packetsLost'] ?? 0.0) / (stats['totalPackets'] ?? 1);
    if (packetLossPercent.isNaN) {
      packetLossPercent = 0;
    }
    double jitter = stats['jitter'] ?? 0;
    double rtt = stats['rtt'] ?? 0;
    double? _score = (stats.length) > 0 ? 100 : null;
    if (_score != null) {
      _score -= packetLossPercent * 50 > 50 ? 50 : packetLossPercent * 50;
      _score -= ((jitter / 30) * 25 > 25 ? 25 : (jitter / 30) * 25);
      _score -= ((rtt / 300) * 25 > 25 ? 25 : (rtt / 300) * 25);
    }
    setState(() {
      score = _score != null ? (_score / 10).toInt() : null;
    });
  }

  @override
  void dispose() {
    if (statsTimer != null) {
      statsTimer?.cancel();
    }
    super.dispose();
  }
}
