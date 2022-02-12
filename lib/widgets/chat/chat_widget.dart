import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/rtc.dart';

class ChatWidget extends StatelessWidget {
  final bool isLocalParticipant;
  final PubSubMessage message;
  const ChatWidget(
      {Key? key, required this.isLocalParticipant, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isLocalParticipant ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 12.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).primaryColor,
        ),
        child: Column(
          crossAxisAlignment: isLocalParticipant
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              isLocalParticipant ? "You" : message.senderName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.message,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              message.timestamp.toLocal().format('h:i a'),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
