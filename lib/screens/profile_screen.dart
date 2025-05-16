import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vello/helper/dialogs.dart';
import 'package:vello/models/chat_user.dart';

import '../api/apis.dart';
import '../main.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<ChatUser> list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.deepOrange,
          onPressed: () async {
            Dialogs.showProgressBar(context);
            await APIs.auth.signOut();
            await GoogleSignIn().signOut().then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            });
          },
          icon: const Icon(Icons.logout),
          label: Text('Выйти из аккаунта'),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
        child: Column(
          children: [
            SizedBox(width: mq.width, height: mq.height * 0.03),

            Stack(
              children: [
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

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: MaterialButton(
                    onPressed: () {},
                    shape: CircleBorder(),
                    color: Colors.white,
                    child: const Icon(Icons.edit, color: Colors.orange),
                  ),
                ),
              ],
            ),

            SizedBox(width: mq.width, height: mq.height * 0.03),

            Text(
              widget.user.email,
              style: const TextStyle(color: Colors.orange, fontSize: 20),
            ),

            SizedBox(width: mq.width, height: mq.height * 0.05),

            TextFormField(
              initialValue: widget.user.name,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'например Павел Галуха',
                label: Text('Имя'),
              ),
            ),

            SizedBox(width: mq.width, height: mq.height * 0.02),

            TextFormField(
              initialValue: widget.user.about,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.info_outline, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'например Чувствую себя хорошо',
                label: Text('О вас'),
              ),
            ),

            SizedBox(width: mq.width, height: mq.height * 0.05),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                maximumSize: Size(mq.width * 0.4, mq.height * 0.06),
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange,
              ),
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('Обновить', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
