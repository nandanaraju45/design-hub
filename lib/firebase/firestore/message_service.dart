import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/models/message_model.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to messages subcollection
  CollectionReference _messagesRef(String chatId) {
    return _firestore.collection('chats').doc(chatId).collection('messages');
  }

  /// Store a message under a specific chat
  Future<String> sendMessage(String chatId, MessageModel message) async {
    try {
      final docRef = await _messagesRef(chatId).add(message.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  /// Stream of all messages in a chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    try {
      return _messagesRef(chatId)
          .orderBy('sentAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                return MessageModel.fromMap(
                    doc.data() as Map<String, dynamic>, doc.id);
              }).toList());
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  /// Get a specific message by ID
  Future<MessageModel?> getMessageById(String chatId, String messageId) async {
    try {
      final doc = await _messagesRef(chatId).doc(messageId).get();
      if (doc.exists) {
        return MessageModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching message by ID: $e');
    }
  }
}
