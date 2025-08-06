import 'package:cloud_firestore/cloud_firestore.dart';

class DesignModel {
  final String id;
  final String name;
  final String caption;
  final List<String> images;
  final String designerId;
  final Timestamp postedAt;
  double reviewsCount;
  List<String> likedBy;
  final DesignCategory category;

  DesignModel({
    this.id = '', // Default empty if not provided
    required this.name,
    required this.caption,
    required this.images,
    required this.designerId,
    required this.postedAt,
    required this.likedBy,
    required this.reviewsCount,
    required this.category,
  });

  // From Map (for reading from Firestore)
  factory DesignModel.fromMap(Map<String, dynamic> map, String documentId) {
    return DesignModel(
      id: documentId,
      name: map['name'] ?? '',
      caption: map['caption'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      designerId: map['designerId'] ?? '',
      postedAt: map['postedAt'] ?? Timestamp.now(),
      likedBy: List<String>.from(map['likedBy'] ?? []),
      reviewsCount: (map['reviewsCount'] ?? 0).toDouble(),
      category: DesignCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => DesignCategory.handCraft, // default category
      ),
    );
  }

  // To Map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'caption': caption,
      'images': images,
      'designerId': designerId,
      'postedAt': postedAt,
      'likedBy': likedBy,
      'reviewsCount': reviewsCount,
      'category': category.name,
    };
  }
}

enum DesignCategory {
  jwellery,
  furnitureDesign,
  interiorDesign,
  dressDesign,
  homeDecor,
  pottery,
  handCraft,
  mehendi,
}
