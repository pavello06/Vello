import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vello/models/chat_user.dart';
import 'package:vello/screens/profile_screen.dart';
import 'package:vello/widgets/chat_user_card.dart';

import '../api/apis.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(CupertinoIcons.home),
        title: const Text('Vello'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(user: APIs.me)),
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add_comment_rounded),
        ),
      ),
      body: StreamBuilder(
        stream: APIs.getAllUsers(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              if (list.isNotEmpty) {
                return ListView.builder(
                  itemCount: list.length,
                  padding: EdgeInsets.only(top: mq.height * 0.01),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatUserCard(user: list[index]);
                  },
                );
              } else {
                return Center(
                  child: Text(
                    'No connections found!',
                    style: TextStyle(fontSize: 20, color: Colors.orange),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
