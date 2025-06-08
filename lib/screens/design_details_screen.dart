import 'package:flutter/material.dart';

class DesignDetailsScreen extends StatefulWidget {
  const DesignDetailsScreen({super.key});

  @override
  State<DesignDetailsScreen> createState() => _DesignDetailsScreenState();
}

class _DesignDetailsScreenState extends State<DesignDetailsScreen> {
  final List<String> imageUrls = [
    'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
    'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
    'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
  ];

  final String title = 'Elegant Mehendi Design';
  final String description =
      'This mehendi design blends traditional motifs with a modern twist, perfect for weddings and festive occasions. Crafted by expert hands, each stroke reflects artistic precision.';

  final int likes = 245;

  final TextEditingController _reviewController = TextEditingController();

  List<Map<String, String>> reviewData = [
    {
      'name': 'Anjali',
      'profileUrl':
          'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
      'text': 'Absolutely stunning design!',
    },
    {
      'name': 'Rahul',
      'profileUrl':
          'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
      'text': 'Perfect for my engagement!',
    },
    {
      'name': 'Meera',
      'profileUrl':
          'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
      'text': 'Loved the detailing and elegance.',
    },
  ];

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
              _buildContactButtons(),
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
    );
  }

  // Top Image Carousel
  Widget _buildImageCarousel() {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(
            imageUrls[index],
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
            title,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red),
              const SizedBox(width: 4),
              Text('$likes likes', style: const TextStyle(fontSize: 16)),
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
              onPressed: () {},
              icon: const Icon(Icons.message),
              label: const Text('Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
          ..._buildReviewList(),
          const SizedBox(height: 20),
          _buildReviewInput(),
        ],
      ),
    );
  }

  // Render Each Review
  List<Widget> _buildReviewList() {
    return reviewData.map((review) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(review['profileUrl']!),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(review['text']!),
                ],
              ),
            ),
          ],
        ),
      );
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
              if (_reviewController.text.trim().isNotEmpty) {
                setState(() {
                  reviewData.add({
                    'name': 'You',
                    'profileUrl': 'https://i.pravatar.cc/150?img=69',
                    'text': _reviewController.text.trim(),
                  });
                  _reviewController.clear();
                });
              }
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
