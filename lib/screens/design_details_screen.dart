import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/firebase/firestore/chat_service.dart';
import 'package:design_hub/firebase/firestore/design_service.dart';
import 'package:design_hub/firebase/firestore/message_service.dart';
import 'package:design_hub/firebase/firestore/user_service.dart';
import 'package:design_hub/models/chat_model.dart';
import 'package:design_hub/models/design_model.dart';
import 'package:design_hub/models/message_model.dart';
import 'package:design_hub/models/review_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/routes/routes.dart';
import 'package:design_hub/screens/chat_list_screen.dart';
import 'package:flutter/material.dart';

class DesignDetailsScreen extends StatefulWidget {
  final DesignModel design;
  final UserModel user;
  const DesignDetailsScreen(
      {super.key, required this.design, required this.user});

  @override
  State<DesignDetailsScreen> createState() => _DesignDetailsScreenState();
}

class _DesignDetailsScreenState extends State<DesignDetailsScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final _userService = UserService();
  final _designService = DesignService();
  List<ReviewModel> _reviews = [];
  bool isReviewsLoading = false;

  String _generateSortedCombinedChatId(String userId1, String userId2) {
    final combined = userId1 + userId2;
    final sortedChars = combined.split('')..sort();
    return sortedChars.join();
  }

  Future<void> _sentPostInterestedMessage() async {
    final messageService = MessageService();
    final chatService = ChatService();
    final chatId = _generateSortedCombinedChatId(
      widget.user.id,
      widget.design.designerId,
    );
    final postMessage = MessageModel(
      senderId: widget.user.id,
      id: '',
      content: widget.design.id,
      messageType: MessageType.design,
      sentAt: Timestamp.now(),
    );
    final textMessage = MessageModel(
      senderId: widget.user.id,
      id: '',
      content: 'Im interested in this design',
      messageType: MessageType.text,
      sentAt: Timestamp.now(),
    );

    await messageService.sendMessage(chatId, postMessage);
    final lastMessageId = await messageService.sendMessage(chatId, textMessage);

    final chat = ChatModel(
      id: chatId,
      users: [widget.user.id, widget.design.designerId],
      lastMessageId: lastMessageId,
      lastMessageTimestamp: Timestamp.now(),
    );

    await chatService.saveChat(chat);
  }

  Future<void> _addReview() async {
    if (_reviewController.text.trim().isNotEmpty) {
      final review = ReviewModel(
        content: _reviewController.text.trim(),
        reviewerId: widget.user.id,
        reviewedAt: DateTime.now(),
      );
      await _designService.addReview(widget.design.id, review);
      setState(() {
        _reviews.add(review);
      });
      _reviewController.clear();
    }
  }

  Future<void> _fetchReviews() async {
    setState(() {
      isReviewsLoading = true;
    });
    final fetchedReviews = await _designService.getReviews(widget.design.id);
    setState(() {
      isReviewsLoading = false;
      _reviews = fetchedReviews;
    });
  }

  Future<void> _deletePost() async {
    final design = widget.design;
    design.isDeleted = true;
    await _designService.addDesign(design);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildImageCarousel(),
              _buildProductInfo(),
              widget.user.id != widget.design.designerId &&
                      widget.user.userType != UserType.admin
                  ? _buildContactButtons()
                  : SizedBox(),
              _buildReviewSection(),
              const SizedBox(height: 20),
            ]),
          ),
        ],
      ),
    );
  }

  // AppBar
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      pinned: true,
      expandedHeight: 60,
      title: const Text(
        'Design Details',
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        if ((widget.user.userType == UserType.designer &&
                widget.user.id == widget.design.designerId) ||
            widget.user.userType == UserType.admin)
          IconButton(
            onPressed: _deletePost,
            icon: Icon(Icons.delete),
          )
      ],
    );
  }

  // Top Image Carousel
  Widget _buildImageCarousel() {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: widget.design.images.length,
        itemBuilder: (context, index) {
          return Image.network(
            widget.design.images[index],
            fit: BoxFit.cover,
            width: double.infinity,
          );
        },
      ),
    );
  }

  // Product Info
  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.design.name,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            widget.design.caption,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                '${widget.design.likedBy.length} likes',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Contact Buttons
  Widget _buildContactButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await _sentPostInterestedMessage();
                Navigator.push(
                  context,
                  MyRoutes.createSlideFadeRoute(
                    ChatListScreen(user: widget.user),
                  ),
                );
              },
              icon: const Icon(Icons.message),
              label: const Text('Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Review Section
  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const Text(
            'Reviews',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          if (isReviewsLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_reviews.isEmpty)
            Text('No reviews yet'),
          ..._buildReviewList(_reviews),
          const SizedBox(height: 20),
          widget.user.userType != UserType.admin &&
                  widget.user.id != widget.design.designerId
              ? _buildReviewInput()
              : SizedBox(),
        ],
      ),
    );
  }

  // Render Each Review
  List<Widget> _buildReviewList(List<ReviewModel> reviews) {
    return reviews.map((review) {
      return FutureBuilder(
          future: _userService.getUserById(review.reviewerId),
          builder: (context, user) {
            if (user.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            }
            if (user.hasError) {
              return Text('Error occured');
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.data!.profileImageUrl),
                    radius: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.data!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(review.content),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
    }).toList();
  }

  // Review Input Field
  Widget _buildReviewInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Write a Review',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _reviewController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Share your experience...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              _addReview();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit'),
          ),
        )
      ],
    );
  }
}
