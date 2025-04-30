import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/models/design_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/widgets/design_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomerHomeScreen extends StatefulWidget {

  final UserModel user;
  const CustomerHomeScreen({super.key, required this.user});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'All';

  bool isLoading = true;

  List<String> categories = [
    'All',
    'Jewellery',
    'Furniture',
    'Interior',
    'Dress',
    'Home Decor',
    'Pottery',
    'Handcraft',
    'Mehendi',
  ];

  // Dummy data
  List<DesignModel> designs = List.generate(
    10,
    (index) => DesignModel(
      name: 'Beautiful Design ${index + 1}',
      caption: 'A stunning piece perfect for your needs!',
      images: [
        'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
      ],
      designerId: 'designer_$index',
      postedAt: Timestamp.now(),
      likedBy: [],
      reviewsCount: (index * 1.2) + 4,
      category: DesignCategory.values[index % DesignCategory.values.length],
    ),
  );

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData ()async{
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Skeletonizer(
        enabled: isLoading,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildCategories(),
            const SizedBox(height: 10),
            _buildDesignGrid(),
          ],
        ),
      ),
    );
  }

  // ================== SUB WIDGETS ==================

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopRow(),
          const SizedBox(height: 20),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Design Hub',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () {
            // Navigate to chats
          },
          icon: const Icon(
            FontAwesomeIcons.solidComments,
            color: Colors.white,
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search for designs...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.blue),
        ),
        onChanged: (value) {
          setState(() {
            // update UI if needed
          });
        },
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory == cat;
          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                selectedCategory = cat;
              });
            },
            selectedColor: Colors.blue,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
            side: const BorderSide(color: Colors.blue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesignGrid() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GridView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          itemCount: designs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            final design = designs[index];
            return DesignCard(
              design: design,
              isLiked: false,
              onLikePressed: () {
                // Handle Like
              },
            );
          },
        ),
      ),
    );
  }
}
