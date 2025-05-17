import 'package:flutter/material.dart';
import 'package:vello/api/apis.dart';

import '../helper/date_util.dart';
import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  final Message message;

  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.senderId
        ? _ourMessage()
        : _senderMessage();
  }

  Widget _senderMessage() {
    if (widget.message.readAt.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * 0.04,
              vertical: mq.height * 0.01,
            ),
            padding: EdgeInsets.all(mq.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              border: Border.all(color: Colors.lightBlue),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(widget.message.message, style: TextStyle(fontSize: 15)),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
            DateUtil.getFormattedTime(
              context: context,
              time: widget.message.sentAt,
            ),
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _ourMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width * 0.04),

            if (widget.message.readAt.isNotEmpty)
              Icon(Icons.done_all_rounded, color: Colors.green),

            SizedBox(width: 2),

            Text(
              DateUtil.getFormattedTime(
                context: context,
                time: widget.message.sentAt,
              ),
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),

        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * 0.04,
              vertical: mq.height * 0.01,
            ),
            padding: EdgeInsets.all(mq.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              border: Border.all(color: Colors.lightGreen),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Text(widget.message.message, style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
