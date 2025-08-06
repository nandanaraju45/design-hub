import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/models/chat_model.dart';

class ChatService {
  final CollectionReference _chatsRef =
      FirebaseFirestore.instance.collection('chats');

  // Method to store a ChatModel
  Future<void> saveChat(ChatModel chat) async {
    try {
      await _chatsRef.doc(chat.id).set(chat.toMap());
    } catch (e) {
      throw Exception('Error saving chat: $e');
    }
  }

  // Stream of chats where 'users' array contains the given userId
  Stream<List<ChatModel>> getChatsForUser(String userId) {
    try {
      return _chatsRef
          .where('users', arrayContains: userId)
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                return ChatModel.fromMap(
                    doc.data() as Map<String, dynamic>, doc.id);
              }).toList());
    } catch (e) {
      throw Exception('Error getting chat stream: $e');
    }
  }
}
