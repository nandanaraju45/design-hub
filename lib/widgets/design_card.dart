import 'package:design_hub/firebase/firestore/design_service.dart';
import 'package:design_hub/firebase/firestore/user_service.dart';
import 'package:design_hub/models/design_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class DesignCard extends StatefulWidget {
  final DesignModel design;
  final VoidCallback onPressed;
  final UserModel user;

  const DesignCard({
    super.key,
    required this.design,
    required this.onPressed,
    required this.user,
  });

  @override
  State<DesignCard> createState() => _DesignCardState();
}

class _DesignCardState extends State<DesignCard> {
  // ignore: unused_field
  int _currentImage = 0;
  String? _name;

  void _likePost(DesignModel design) {
    final designService = DesignService();
    design.likedBy.add(widget.user.id);
    designService.addDesign(design);
    setState(() {});
  }

  void _dislikePost(DesignModel design) {
    final designService = DesignService();
    design.likedBy.remove(widget.user.id);
    designService.addDesign(design);
    setState(() {});
  }

  void _getName() async {
    final userService = UserService();
    final user = await userService.getUserById(widget.design.designerId);
    setState(() {
      _name = user?.name;
    });
  }

  @override
  void initState() {
    super.initState();
    _getName();
  }

  @override
  Widget build(BuildContext context) {
    bool isLiked = widget.design.likedBy.contains(widget.user.id);

    return GestureDetector(
      onTap: widget.onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Image slider
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: double.infinity,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImage = index;
                          });
                        },
                      ),
                      items: widget.design.images.map((imageUrl) {
                        return CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey[300],
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        );
                      }).toList(),
                    ),
                    // Like button on top-right
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: () {
                          isLiked
                              ? _dislikePost(widget.design)
                              : _likePost(widget.design);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Details section
              Expanded(
                flex: 5,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Design name
                      Text(
                        widget.design.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Design caption
                      Text(
                        widget.design.caption,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Designer name + Like count
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _name ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.favorite,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.design.likedBy.length.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
