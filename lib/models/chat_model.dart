import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> users;
  String lastMessageId;
  Timestamp lastMessageTimestamp;

  ChatModel({
    required this.id,
    required this.users,
    required this.lastMessageId,
    required this.lastMessageTimestamp,
  });

  // Convert a Firestore map to ChatModel
  factory ChatModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ChatModel(
      id: documentId,
      users: List<String>.from(map['users'] ?? []),
      lastMessageId: map['lastMessageId'] ?? '',
      lastMessageTimestamp: map['lastMessageTimestamp'] ?? Timestamp.now(),
    );
  }

  // Convert ChatModel to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'users': users,
      'lastMessageId': lastMessageId,
      'lastMessageTimestamp': lastMessageTimestamp,
    };
  }
}
