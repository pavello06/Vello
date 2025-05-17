import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../helper/date_util.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/chat_user.dart';
import 'auth/login_screen.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.user.name)),

        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Joined On: ',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
            Text(
                DateUtil.getLastMessageTime(
                    context: context,
                    time: widget.user.createdAt,
                    showYear: true),
                style: const TextStyle(color: Colors.black54, fontSize: 15)),
          ],
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(width: mq.width, height: mq.height * 0.03),

                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.1),
                  child: CachedNetworkImage(
                    width: mq.height * 0.2,
                    height: mq.height * 0.2,
                    imageUrl: widget.user.image,
                    errorWidget:
                        (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person),
                        ),
                  ),
                ),

                SizedBox(width: mq.width, height: mq.height * 0.03),

                Text(
                  widget.user.email,
                  style: const TextStyle(color: Colors.orange, fontSize: 20),
                ),

                SizedBox(width: mq.width, height: mq.height * 0.05),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'About: ',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    Text(
                      widget.user.about,
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),

                SizedBox(width: mq.width, height: mq.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
