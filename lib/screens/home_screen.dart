import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<ChatUser> _list = [];

  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) APIs.updateActiveStatus(true);
        if (message.toString().contains('pause')) APIs.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope<bool>(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, bool? result) {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return;
          }
          Future.delayed(
            const Duration(milliseconds: 300),
            SystemNavigator.pop,
          );
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title:
                _isSearching
                    ? TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Name, Email, ...',
                      ),
                      autofocus: true,
                      style: TextStyle(
                        fontSize: 17,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                      onChanged: (value) {
                        _searchList.clear();

                        for (var i in _list) {
                          if (i.name.toLowerCase().contains(
                                value.toLowerCase(),
                              ) ||
                              i.email.toLowerCase().contains(
                                value.toLowerCase(),
                              )) {
                            _searchList.add(i);
                          }
                        }
                        setState(() {
                          _searchList;
                        });
                      },
                    )
                    : const Text('Vello'),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(user: APIs.me),
                    ),
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
                  return const Center(child: CircularProgressIndicator());

                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  _list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                      [];

                  if (_list.isNotEmpty) {
                    return ListView.builder(
                      itemCount:
                          _isSearching ? _searchList.length : _list.length,
                      padding: EdgeInsets.only(top: mq.height * 0.01),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                          user:
                              _isSearching ? _searchList[index] : _list[index],
                        );
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
        ),
      ),
    );
  }
}
