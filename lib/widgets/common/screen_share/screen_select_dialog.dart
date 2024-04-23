import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:videosdk/videosdk.dart';
import '../../../constants/colors.dart';
import 'thumbnail_widget.dart';

// ignore: must_be_immutable
class ScreenSelectDialog extends Dialog {
  ScreenSelectDialog({Key? key, required this.meeting}) : super(key: key) {
    _getSources();
    _subscriptions.add(desktopCapturer.onAdded.stream.listen((source) {
      _sources[source.id] = source;
      _stateSetter?.call(() {});
    }));

    _subscriptions.add(desktopCapturer.onRemoved.stream.listen((source) {
      _sources.remove(source.id);
      _stateSetter?.call(() {});
    }));

    _subscriptions
        .add(desktopCapturer.onThumbnailChanged.stream.listen((source) {
      _stateSetter?.call(() {});
    }));
  }

  

  void _setSources(List<DesktopCapturerSource> source) {
    source.forEach((element) {
      _sources[element.id] = element;
    });

    _stateSetter?.call(() {});
  }

  final Map<String, DesktopCapturerSource> _sources = {};
  SourceType _sourceType = SourceType.Screen;
  DesktopCapturerSource? _selected_source;
  final List<StreamSubscription<DesktopCapturerSource>> _subscriptions = [];
  StateSetter? _stateSetter;
  Timer? _timer;
  final Room meeting;

  void _ok(context) async {
    _timer?.cancel();
    for (var element in _subscriptions) {
      element.cancel();
    }
    Navigator.pop<DesktopCapturerSource>(context, _selected_source);
  }

  void _cancel(context) async {
    _timer?.cancel();
    for (var element in _subscriptions) {
      element.cancel();
    }
    Navigator.pop<DesktopCapturerSource>(context, null);
  }

  Future<void> _getSources() async {
    try {
      var sources = await desktopCapturer.getSources(types: [_sourceType]);
      _timer?.cancel();
      _timer = Timer.periodic(Duration(seconds: 3), (timer) {
        desktopCapturer.updateSources(types: [_sourceType]);
      });
      _sources.clear();
      sources.forEach((element) {
        _sources[element.id] = element;
      });
      _stateSetter?.call(() {});
      return;
    } catch (e) {
      print(e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
          child: Container(
        width: 640,
        height: 560,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: black700,
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                children: <Widget>[
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Choose what to share',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      child: const Icon(Icons.close),
                      onTap: () => _cancel(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    if (context.mounted) {
                      _stateSetter = setState;
                    }
                    return DefaultTabController(
                      length: 2,
                      child: Column(
                        children: <Widget>[
                          Container(
                            constraints:
                                const BoxConstraints.expand(height: 24),
                            child: TabBar(
                                indicatorColor: purple,
                                onTap: (value) => Future.delayed(Duration.zero, () {
                                      _sourceType = value == 0
                                          ? SourceType.Screen
                                          : SourceType.Window;
                                      _getSources();
                                    }),
                                tabs: const [
                                  Tab(
                                      child: Text(
                                    'Entire Screen',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )),
                                  Tab(
                                      child: Text(
                                    'Window',
                                    style: TextStyle(color: Colors.white),
                                  )),
                                ]),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Expanded(
                            child: TabBarView(children: [
                              Align(
                                  alignment: Alignment.center,
                                  child: GridView.count(
                                    crossAxisSpacing: 8,
                                    crossAxisCount: 2,
                                    children: _sources.entries
                                        .where((element) =>
                                                element.value.type ==
                                                SourceType.Screen)
                                        .map((e) => ThumbnailWidget(
                                              onTap: (source) {
                                                if (context.mounted) {
                                                  setState(() {
                                                    _selected_source = source;
                                                  });
                                                }
                                              },
                                              source: e.value,
                                              selected: _selected_source?.id ==
                                                  e.value.id,
                                            ))
                                        .toList(),
                                  )),
                              Align(
                                  alignment: Alignment.center,
                                  child: GridView.count(
                                    crossAxisSpacing: 8,
                                    crossAxisCount: 3,
                                    children: _sources.entries
                                            .where((element) =>
                                                element.value.type ==
                                                SourceType.Window)
                                        .map((e) => ThumbnailWidget(
                                              onTap: (source) {
                                                if (context.mounted) {
                                                  setState(() {
                                                    _selected_source = source;
                                                  });
                                                }
                                              },
                                              source: e.value,
                                              selected: _selected_source?.id ==
                                                  e.value.id,
                                            ))
                                        .toList(),
                                  )),
                            ]),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ButtonBar(
                children: <Widget>[
                  MaterialButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      _cancel(context);
                    },
                  ),
                  MaterialButton(
                    color: purple,
                    child: const Text(
                      'Share',
                    ),
                    onPressed: () {
                      _ok(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
