import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vello/models/message.dart';

import '../models/chat_user.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Cloudinary storage = Cloudinary.unsignedConfig(
    cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME']!,
  );

  static User get user => auth.currentUser!;

  static late ChatUser me;

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: 'Hi, I\'m using Vello!',
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return APIs.firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> updateProfilePicture(File file) async {
    final response = await storage.unsignedUpload(
      file: file.path,
      uploadPreset: dotenv.env['CLOUDINARY_UPLOAD_PRESET']!,
      fileBytes: file.readAsBytesSync(),
      resourceType: CloudinaryResourceType.image,
      folder: dotenv.env['CLOUDINARY_PROFILE_PICTURES_FOLDER']!,
      fileName: '${user.uid}${DateTime.now().millisecondsSinceEpoch}',
    );

    me.image = response.secureUrl!;
    log(response.secureUrl!);
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  static String getConversationID(String id) =>
      user.uid.hashCode <= id.hashCode
          ? '${user.uid}_$id'
          : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
    ChatUser user,
  ) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent_at', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
    ChatUser chatUser,
    String msg,
    Type type,
  ) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final message = Message(
      readAt: '',
      message: msg,
      type: type,
      senderId: user.uid,
      sentAt: time,
      recipientId: chatUser.id,
    );

    final ref = firestore.collection(
      'chats/${getConversationID(chatUser.id)}/messages/',
    );
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.senderId)}/messages/')
        .doc(message.sentAt)
        .update({'read_at': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
    ChatUser user,
  ) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent_at', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendImage(ChatUser chatUser, File file) async {
    final response = await storage.unsignedUpload(
      file: file.path,
      uploadPreset: dotenv.env['CLOUDINARY_UPLOAD_PRESET']!,
      fileBytes: file.readAsBytesSync(),
      resourceType: CloudinaryResourceType.image,
      folder:
          '${dotenv.env['CLOUDINARY_IMAGES_FOLDER']!}/${getConversationID(chatUser.id)}',
      fileName: '${DateTime.now().millisecondsSinceEpoch}',
    );

    final imageUrl = response.secureUrl!;
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
    ChatUser user,
  ) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: user.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }
}
