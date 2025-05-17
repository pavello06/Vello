import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/chat_user.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.deepOrange,
            onPressed: () async {
              Dialogs.showProgressBar(context);

              APIs.updateActiveStatus(false);

              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  APIs.auth = FirebaseAuth.instance;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                });
              });
            },
            icon: const Icon(Icons.logout),
            label: Text('Logout'),
          ),
        ),

        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.height * 0.03),

                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              mq.height * 0.1,
                            ),
                            child: Image.file(
                              File(_image!),
                              width: mq.height * 0.2,
                              height: mq.height * 0.2,
                              fit: BoxFit.cover,
                            ),
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(
                              mq.height * 0.1,
                            ),
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
                          onPressed: () {
                            _showBottomSheet();
                          },
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
                    onSaved: (value) => APIs.me.name = value ?? '',
                    validator:
                        (value) =>
                            value != null && value.isNotEmpty
                                ? null
                                : 'Required field',
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'eg. Pavel Halukha',
                      label: Text('Name'),
                    ),
                  ),

                  SizedBox(width: mq.width, height: mq.height * 0.02),

                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (value) => APIs.me.about = value ?? '',
                    validator:
                        (value) =>
                            value != null && value.isNotEmpty
                                ? null
                                : 'Required field',
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'eg. Feeling good',
                      label: Text('About'),
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackBar(
                            context,
                            'Profile updated successfully',
                          );
                        });
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Update', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder:
          (_) => ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
              top: mq.height * 0.03,
              bottom: mq.height * 0.08,
            ),
            children: [
              Text(
                'Pick profile picture',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange,
                ),
              ),

              SizedBox(height: mq.height * 0.02),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        APIs.updateProfilePicture(File(_image!));
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('images/camera.png'),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        APIs.updateProfilePicture(File(_image!));
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('images/add_image.png'),
                  ),
                ],
              ),
            ],
          ),
    );
  }
}
