import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../constants/colors.dart';

class ThumbnailWidget extends StatefulWidget {
  const ThumbnailWidget(
      {Key? key,
      required this.source,
      required this.selected,
      required this.onTap})
      : super(key: key);
  final DesktopCapturerSource source;
  final bool selected;
  final Function(DesktopCapturerSource) onTap;

  @override
  _ThumbnailWidgetState createState() => _ThumbnailWidgetState();
}

class _ThumbnailWidgetState extends State<ThumbnailWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Container(
          decoration: widget.selected
              ? BoxDecoration(border: Border.all(width: 2, color: purple))
              : null,
          child: InkWell(
            onTap: () {
              widget.onTap(widget.source);
            },
            child: widget.source.thumbnail != null
                ? Image.memory(
                    widget.source.thumbnail!,
                    gaplessPlayback: true,
                    alignment: Alignment.center,
                  )
                : Container(),
          ),
        )),
        Text(
          widget.source.name.length > 10
              ? "${widget.source.name.substring(0, 10)}..."
              : widget.source.name,
          maxLines: 1,
          style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight:
                  widget.selected ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}
