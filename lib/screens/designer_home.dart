import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/models/design_model.dart';
import 'package:design_hub/models/designer_detailes_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/routes/routes.dart';
import 'package:design_hub/screens/design_details_screen.dart';
import 'package:design_hub/screens/post_design_screen.dart';
import 'package:design_hub/widgets/design_card.dart';
import 'package:flutter/material.dart';

class DesignerHome extends StatefulWidget {
  final UserModel user;
  final DesignerDetailesModel designerDetails;
  const DesignerHome(
      {super.key, required this.user, required this.designerDetails});

  @override
  State<DesignerHome> createState() => _DesignerHomeState();
}

class _DesignerHomeState extends State<DesignerHome> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MyRoutes.createSlideFadeRoute(
              PostDesignScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildDesignGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 16,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(widget.user.profileImageUrl),
          ),
          SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: TextStyle(fontSize: 24),
              ),
              Text(widget.user.email),
              SizedBox(
                height: 10,
              ),
              ElevatedButton.icon(
                onPressed: () {},
                label: Text('Messages'),
                icon: Icon(Icons.message),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              )
            ],
          )
        ],
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
              onPressed: () {
                Navigator.push(
                  context,
                  MyRoutes.createSlideFadeRoute(
                    DesignDetailsScreen(),
                  ),
                );
              },
              onLikePressed: () {},
            );
          },
        ),
      ),
    );
  }
}
