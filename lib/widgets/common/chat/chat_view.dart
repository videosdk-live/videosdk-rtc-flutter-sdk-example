import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';
import 'chat_widget.dart';

// ChatScreen
class ChatView extends StatefulWidget {
  final Room meeting;
  const ChatView({
    Key? key,
    required this.meeting,
  }) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // MessageTextController
  final msgTextController = TextEditingController();

  // Messages shown in the list, oldest first.
  final List<PubSubMessage> _messages = [];

  // Live messages reach both `onMessageReceived` and `onBatchReceived`, and a
  // history replay can restart after a network blip, so the same message can be
  // handed to us more than once. Ids we have already rendered are tracked here.
  final Set<String> _renderedIds = {};

  // False until the first messages land, so an empty list is not shown while
  // the past conversation is still being fetched.
  bool _ready = false;

  // True only once a history batch has arrived that is not the last one, so
  // nothing is announced as loading when the topic has no history, or when the
  // subscribe was rejected and no history is coming at all.
  bool _loadingHistory = false;

  // How many live messages the server could not deliver to this subscriber.
  int _droppedCount = 0;

  @override
  void initState() {
    super.initState();

    // Subscribing 'CHAT' Topic.
    //
    // The subscription stays alive across reconnections, so it is set up once
    // here and never renewed.
    widget.meeting.pubSub
        .subscribe(
          "CHAT",
          messageHandler,
          options: const PubSubSubscribeOptions(
            // Replay at most the last 100 persisted messages.
            oldMessageLimit: 100,
            // Hold messages briefly for a subscriber that falls behind rather
            // than discarding them, so a busy topic loses nothing.
            realtimeOverflow: PubSubRealtimeOverflow.queue,
            maxQueue: 70,
          ),
          // Past messages stream in oldest-first as they load, so a long
          // conversation starts rendering before all of it has arrived.
          onOldMessagesReceived: oldMessagesHandler,
          // A group of live messages that arrived together on a busy topic.
          onBatchReceived: batchHandler,
          // Messages that could not be delivered, including any missed while
          // the connection was down.
          onMessageDrop: messageDropHandler,
        )
        // Resolves once the first history batch is in; the rest keeps arriving
        // through onOldMessagesReceived.
        .then((_) => setState(() => _ready = true));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        flexibleSpace: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "Chat",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: secondaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (_droppedCount > 0)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8), color: black600),
                  child: Text(
                    "$_droppedCount message${_droppedCount == 1 ? '' : 's'} could not be delivered",
                    style: const TextStyle(fontSize: 12, color: black400),
                  ),
                ),
              Expanded(
                child: !_ready
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        reverse: true,
                        child: Column(
                          children: [
                            if (_loadingHistory)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  "Loading earlier messages...",
                                  style:
                                      TextStyle(fontSize: 12, color: black400),
                                ),
                              ),
                            ..._messages
                                .map(
                                  (e) => ChatWidget(
                                    message: e,
                                    isLocalParticipant: e.senderId ==
                                        widget.meeting.localParticipant.id,
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), color: black600),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        controller: msgTextController,
                        onChanged: (value) => setState(() {
                          msgTextController.text;
                        }),
                        decoration: const InputDecoration(
                            hintText: "Write your message",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: black400,
                            )),
                      ),
                    ),
                    GestureDetector(
                      onTap: msgTextController.text.trim().isEmpty
                          ? null
                          : () => widget.meeting.pubSub
                              .publish(
                                "CHAT",
                                msgTextController.text,
                                const PubSubPublishOptions(persist: true),
                              )
                              .then((value) => msgTextController.clear()),
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          width: 45,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: msgTextController.text.trim().isEmpty
                                  ? null
                                  : purple,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.send)),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // A single live message.
  void messageHandler(PubSubMessage message) {
    addMessages([message]);
  }

  // A group of live messages delivered together on a busy topic.
  void batchHandler(List<PubSubMessage> messages) {
    addMessages(messages);
  }

  // Past messages, oldest first. [isLast] marks the final batch of the replay.
  void oldMessagesHandler(List<PubSubMessage> messages, bool isLast) {
    addMessages(messages);
    setState(() {
      _ready = true;
      _loadingHistory = !isLast;
    });
  }

  // Live messages the server could not deliver to this subscriber, including
  // any that arrived while the connection was down.
  void messageDropHandler(int droppedCount) {
    setState(() => _droppedCount += droppedCount);
  }

  // Renders messages the list has not seen before. A live message can arrive
  // while history is still replaying, so the list is kept in timestamp order
  // rather than the order the callbacks fire in.
  void addMessages(List<PubSubMessage> messages) {
    final fresh = messages.where((m) => _renderedIds.add(m.id)).toList();
    if (fresh.isEmpty) return;

    setState(() {
      _messages.addAll(fresh);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  @override
  void dispose() {
    // Detaches this subscriber's message, batch and drop callbacks together.
    widget.meeting.pubSub.unsubscribe("CHAT", messageHandler);
    super.dispose();
  }
}
