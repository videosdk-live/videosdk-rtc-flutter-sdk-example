import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:videosdk/videosdk.dart';
import '../../../constants/colors.dart';
import 'thumbnail_widget.dart';

// ignore: must_be_immutable
class ScreenSelectDialog extends Dialog {
  ScreenSelectDialog({Key? key, required this.meeting}) : super(key: key) {
    meeting.getScreenShareSources().then((value) => _setSources(value));
  }

  void _setSources(List<DesktopCapturerSource> source) {
    _sources = source;
    _stateSetter?.call(() {});
  }

  List<DesktopCapturerSource> _sources = [];
  SourceType _sourceType = SourceType.Screen;
  DesktopCapturerSource? _selected_source;
  StateSetter? _stateSetter;
  final Room meeting;

  void _ok(context) async {
    Navigator.pop<DesktopCapturerSource>(context, _selected_source);
  }

  void _cancel(context) async {
    Navigator.pop<DesktopCapturerSource>(context, null);
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
                                onTap: (value) => _sourceType = value == 0
                                    ? SourceType.Screen
                                    : SourceType.Window,
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
                                    children: _sources
                                        .asMap()
                                        .entries
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
                                    children: _sources
                                        .asMap()
                                        .entries
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
