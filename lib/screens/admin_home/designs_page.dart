import 'package:design_hub/firebase/authentication/authentication.dart';
import 'package:design_hub/firebase/firestore/design_service.dart';
import 'package:design_hub/models/design_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/routes/routes.dart';
import 'package:design_hub/screens/design_details_screen.dart';
import 'package:design_hub/widgets/design_card.dart';
import 'package:flutter/material.dart';

class DesignsPage extends StatefulWidget {
  final UserModel user;
  const DesignsPage({super.key, required this.user});

  @override
  State<DesignsPage> createState() => _DesignsPageState();
}

class _DesignsPageState extends State<DesignsPage> {
  final _searchController = TextEditingController();

  String selectedCategory = 'All';

  bool isLoading = true;

  final authService = Authentication();
  final designService = DesignService();

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

  List<DesignModel> _designs = [];
  List<DesignModel> _filteredDesigns = [];

  Future<void> _loadData() async {
    final fetchedDesigns = await designService.getAllDesigns();
    setState(() {
      isLoading = false;
      _designs = fetchedDesigns;
    });
    _filterDesigns();
  }

  void _filterDesigns() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDesigns = _designs.where((design) {
        final matchesSearch = design.name.toLowerCase().contains(query) ||
            design.caption.toLowerCase().contains(query);

        final matchesCategory = selectedCategory == 'All' ||
            _mapCategoryToDisplayName(design.category) == selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  String _mapCategoryToDisplayName(DesignCategory category) {
    switch (category) {
      case DesignCategory.jwellery:
        return 'Jewellery';
      case DesignCategory.furnitureDesign:
        return 'Furniture';
      case DesignCategory.interiorDesign:
        return 'Interior';
      case DesignCategory.dressDesign:
        return 'Dress';
      case DesignCategory.homeDecor:
        return 'Home Decor';
      case DesignCategory.pottery:
        return 'Pottery';
      case DesignCategory.handCraft:
        return 'Handcraft';
      case DesignCategory.mehendi:
        return 'Mehendi';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: 16),
            _buildSearchBar(),
            SizedBox(height: 16),
            _buildCategories(),
            _buildDesignGrid(),
          ],
        ),
      ),
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
          _filterDesigns();
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
              _filterDesigns();
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
          itemCount: _filteredDesigns.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            final design = _filteredDesigns[index];
            return DesignCard(
              user: widget.user,
              design: design,
              onPressed: () {
                Navigator.push(
                  context,
                  MyRoutes.createSlideFadeRoute(
                    DesignDetailsScreen(user: widget.user, design: design),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
