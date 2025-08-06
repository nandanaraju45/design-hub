import 'package:cloud_firestore/cloud_firestore.dart'; // Only if using Firestore

class ReviewModel {
  String? id; // Nullable, not stored
  final String content;
  final String reviewerId;
  final DateTime reviewedAt;

  ReviewModel({
    this.id,
    required this.content,
    required this.reviewerId,
    required this.reviewedAt,
  });

  // fromMap - when reading from DB
  factory ReviewModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ReviewModel(
      id: id,
      content: map['content'] as String,
      reviewerId: map['reviewerId'] as String,
      reviewedAt: (map['reviewedAt'] as Timestamp).toDate(),
    );
  }

  // toMap - when writing to DB (don't include id)
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'reviewerId': reviewerId,
      'reviewedAt': Timestamp.fromDate(reviewedAt),
    };
  }
}
