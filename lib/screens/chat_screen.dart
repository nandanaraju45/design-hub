import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/cloudinary/cloudinary_service.dart';
import 'package:design_hub/firebase/firestore/chat_service.dart';
import 'package:design_hub/firebase/firestore/design_service.dart';
import 'package:design_hub/firebase/firestore/message_service.dart';
import 'package:design_hub/helpers/image_picker.dart';
import 'package:design_hub/models/chat_model.dart';
import 'package:design_hub/models/message_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/widgets/design_card.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;
  final UserModel currentUser;
  final UserModel otherUser;

  const ChatScreen({
    super.key,
    required this.chat,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final chatService = ChatService();
  final messageService = MessageService();
  final designService = DesignService();
  final cloudinaryService = CloudinaryService();

  void _sendTextMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = MessageModel(
      senderId: widget.currentUser.id,
      id: '',
      content: text,
      messageType: MessageType.text,
      sentAt: Timestamp.now(),
    );

    await messageService.sendMessage(widget.chat.id, message);
    _messageController.clear();
  }

  void _sentImageMessage() async {
    final images = await ImagePickerService().pickImages(useGallery: true);

    if (images != null && images.isNotEmpty) {
      final image = images[0];
      final imageUrl = await cloudinaryService.uploadImageToCloudinary(
        imageFile: image,
        folderName: 'messages',
      );
      if (imageUrl == null) return;

      final message = MessageModel(
        senderId: widget.currentUser.id,
        id: '',
        content: imageUrl,
        messageType: MessageType.image,
        sentAt: Timestamp.now(),
      );

      await messageService.sendMessage(widget.chat.id, message);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _buildAppBar(),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          const Divider(height: 1),
          _buildMessageInput(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.otherUser.profileImageUrl),
          ),
          const SizedBox(width: 10),
          Text(widget.otherUser.name),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<MessageModel>>(
      stream: messageService.getMessages(widget.chat.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(10),
            itemCount: 6,
            itemBuilder: (context, index) => _buildShimmerBubble(),
          );
        }

        final messages = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg.senderId == widget.currentUser.id;
            return _buildMessageBubble(
              messageType: msg.messageType,
              message: msg.content,
              timestamp: msg.sentAt.toDate(),
              isMe: isMe,
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required MessageType messageType,
    required DateTime timestamp,
    required bool isMe,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: messageType == MessageType.text
              ? (isMe ? Colors.blue : Colors.grey[300])
              : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (messageType == MessageType.image)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.red),
                    );
                  },
                ),
              ),
            if (messageType == MessageType.design)
              FutureBuilder(
                future: designService.getDesignById(message),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerDesignCard();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    final design = snapshot.data;
                    return SizedBox(
                      height: 200,
                      child: DesignCard(
                        design: design!,
                        onPressed: () {},
                        user: widget.currentUser,
                      ),
                    );
                  }
                },
              ),
            if (messageType == MessageType.text && message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  message,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                color: messageType == MessageType.text
                    ? (isMe ? Colors.white70 : Colors.black54)
                    : Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image, color: Colors.blue),
              onPressed: _sentImageMessage,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: _sendTextMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          height: 80,
          width: MediaQuery.of(context).size.width * 0.6,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerDesignCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
