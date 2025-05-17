import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vello/helper/date_util.dart';
import 'package:vello/models/chat_user.dart';
import 'package:vello/screens/chat_screen.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/message.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)),
          );
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) {
              _message = list[0];
            }

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.03),
                child: CachedNetworkImage(
                  width: mq.height * 0.055,
                  height: mq.height * 0.055,
                  imageUrl: widget.user.image,
                  errorWidget:
                      (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                ),
              ),
              title: Text(widget.user.name),
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? 'image'
                        : _message!.message
                    : widget.user.about,
                maxLines: 1,
              ),
              trailing:
                  _message == null
                      ? null
                      : _message!.readAt.isEmpty &&
                          _message!.senderId != APIs.user.uid
                      ? SizedBox(
                        width: 15,
                        height: 15,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      )
                      : Text(
                        DateUtil.getLastMessageTime(
                          context: context,
                          time: _message!.sentAt,
                        ),
                        style: TextStyle(color: Colors.orange, fontSize: 15),
                      ),
            );
          },
        ),
      ),
    );
  }
}
