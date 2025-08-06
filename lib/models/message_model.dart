import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final MessageType messageType;
  final Timestamp sentAt;

  MessageModel({
    required this.senderId,
    required this.id,
    required this.content,
    required this.messageType,
    required this.sentAt,
  });

  // Convert Firestore data to MessageModel
  factory MessageModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MessageModel(
      id: documentId,
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      messageType: _messageTypeFromString(map['messageType'] ?? 'text'),
      sentAt: map['sentAt'] ?? Timestamp.now(),
    );
  }

  // Convert MessageModel to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'messageType': messageType.name,
      'sentAt': sentAt,
    };
  }

  // Helper: Convert string to MessageType enum
  static MessageType _messageTypeFromString(String type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'design':
        return MessageType.design;
      case 'text':
      default:
        return MessageType.text;
    }
  }
}

enum MessageType { text, image, design }
