import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vello/helper/date_util.dart';
import 'package:vello/models/message.dart';
import 'package:vello/widgets/message_card.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),

        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: APIs.getAllMessages(widget.user),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return SizedBox();

                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list =
                          data
                              ?.map((e) => Message.fromJson(e.data()))
                              .toList() ??
                          [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                          itemCount: _list.length,
                          padding: EdgeInsets.only(top: mq.height * 0.01),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return MessageCard(message: _list[index]);
                          },
                        );
                      } else {
                        return Center(
                          child: Text(
                            'Say Hi! 👋',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.orange,
                            ),
                          ),
                        );
                      }
                  }
                },
              ),
            ),
            _chatInput(),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.03),
            child: CachedNetworkImage(
              width: mq.height * 0.055,
              height: mq.height * 0.055,
              imageUrl: widget.user.image,
              errorWidget:
                  (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),

          SizedBox(width: 10),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),

              Text(
                'Last seen not available',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mq.height * 0.01,
        horizontal: mq.width * 0.025,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.orange,
                      size: 26,
                    ),
                  ),

                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type something...',
                        hintStyle: TextStyle(color: Colors.orange),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.image,
                      color: Colors.orange,
                      size: 26,
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.orange,
                      size: 26,
                    ),
                  ),

                  SizedBox(width: mq.width * 0.02),
                ],
              ),
            ),
          ),

          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text);
                _textController.text = '';
              }
            },
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 5),
            shape: const CircleBorder(),
            color: Colors.orange,
            child: Icon(Icons.send, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
