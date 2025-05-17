class Message {
  Message({
    required this.readAt,
    required this.message,
    required this.type,
    required this.senderId,
    required this.sentAt,
    required this.recipientId,
  });

  final String readAt;
  final String message;
  final Type type;
  final String senderId;
  final String sentAt;
  final String recipientId;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      readAt: json["read_at"],
      message: json["message"],
      type: Type.values.firstWhere((e) => e.toString() == 'Type.${json["type"]}'),
      senderId: json["sender_id"],
      sentAt: json["sent_at"],
      recipientId: json["recipient_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "read_at": readAt,
    "message": message,
    "type": type.name,
    "sender_id": senderId,
    "sent_at": sentAt,
    "recipient_id": recipientId,
  };
}

enum Type { text, image }
