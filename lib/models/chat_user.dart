class ChatUser {
  late final String image;
  late final String name;
  late final String about;
  late final String createdAt;
  late final String id;
  late final bool isOnline;
  late final String lastActive;
  late final String email;
  late final String pushToken;

  ChatUser({
    required this.image,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.id,
    required this.isOnline,
    required this.lastActive,
    required this.email,
    required this.pushToken,
  });

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    name = json['name'] ?? '';
    about = json['about'] ?? '';
    createdAt = json['created_at'] ?? '';
    id = json['id'] ?? '';
    isOnline = json['is_online'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['image'] = image;
    data['name'] = name;
    data['about'] = about;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['is_online'] = isOnline;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    return data;
  }
}
