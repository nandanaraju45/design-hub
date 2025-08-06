import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/firebase/firestore/chat_service.dart';
import 'package:design_hub/firebase/firestore/message_service.dart';
import 'package:design_hub/firebase/firestore/user_service.dart';
import 'package:design_hub/models/chat_model.dart';
import 'package:design_hub/models/message_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/routes/routes.dart';
import 'package:design_hub/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  final UserModel user;
  const ChatListScreen({super.key, required this.user});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final chatService = ChatService();
  final userService = UserService();
  final messageService = MessageService();

  String formatTimestamp(Timestamp timestamp) {
    final DateTime messageTime = timestamp.toDate();
    final DateTime now = DateTime.now();

    final isToday = messageTime.year == now.year &&
        messageTime.month == now.month &&
        messageTime.day == now.day;

    final isYesterday = messageTime.year == now.year &&
        messageTime.month == now.month &&
        messageTime.day == now.day - 1;

    if (isToday) {
      return DateFormat('hh:mm a').format(messageTime); // e.g., 10:45 PM
    } else if (isYesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(messageTime); // e.g., 26 Jun 2025
    }
  }

  Future<UserModel?> _getUser(String id) async {
    final user = await userService.getUserById(id);
    return user;
  }

  Future<MessageModel?> _getMessage(String chatId, String messageId) async {
    final message = await messageService.getMessageById(chatId, messageId);
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildChatsList(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      title: const Text('Chats'),
    );
  }

  Widget _buildChatsList() {
    return StreamBuilder<List<ChatModel>>(
      stream: chatService.getChatsForUser(widget.user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No chats yet'));
        }

        final chats = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          itemBuilder: (context, index) => _buildChatTile(chats[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemCount: chats.length,
        );
      },
    );
  }

  Widget _buildChatTile(ChatModel chat) {
    final otherUserId =
        chat.users[0] == widget.user.id ? chat.users[1] : chat.users[0];

    return FutureBuilder(
      future: Future.wait([
        _getUser(otherUserId),
        _getMessage(chat.id, chat.lastMessageId),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Loading...'),
            subtitle: Text('Please wait'),
          );
        }

        final UserModel? otherUser = snapshot.data?[0];
        final MessageModel? message = snapshot.data?[1];

        if (otherUser == null || message == null) {
          return const ListTile(
            title: Text('Unknown user'),
            subtitle: Text('No message available'),
          );
        }

        String subtitleText;
        TextStyle subtitleStyle;

        if (message.messageType == MessageType.text) {
          subtitleText = message.content;
          subtitleStyle = const TextStyle(fontWeight: FontWeight.normal);
        } else if (message.messageType == MessageType.image) {
          subtitleText = 'Image message';
          subtitleStyle = const TextStyle(fontWeight: FontWeight.bold);
        } else {
          subtitleText = 'Design';
          subtitleStyle = const TextStyle(fontWeight: FontWeight.bold);
        }

        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MyRoutes.createSlideFadeRoute(
                ChatScreen(
                  chat: chat,
                  currentUser: widget.user,
                  otherUser: otherUser,
                ),
              ),
            );
          },
          leading: CircleAvatar(
            backgroundImage: NetworkImage(otherUser.profileImageUrl),
          ),
          title: Text(otherUser.name),
          subtitle: Text(
              overflow: TextOverflow.ellipsis,
              subtitleText,
              style: subtitleStyle),
          trailing: Text(formatTimestamp(chat.lastMessageTimestamp)),
        );
      },
    );
  }
}
