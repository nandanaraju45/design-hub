import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/models/design_model.dart';

class DesignerDetailesModel {
  final String uid;
  final String qualification;
  bool isApproved;
  bool isQuizPassed;
  bool isDeclined;
  Timestamp? quizPassedAt;
  final DesignCategory category;
  int failedAttempts;

  DesignerDetailesModel({
    required this.uid,
    required this.qualification,
    required this.category,
    required this.isApproved,
    required this.isDeclined,
    required this.isQuizPassed,
    required this.quizPassedAt,
    this.failedAttempts = 0,
  });

  factory DesignerDetailesModel.fromMap(Map<String, dynamic> map) {
    return DesignerDetailesModel(
      uid: map['uid'] ?? '',
      qualification: map['qualification'] ?? '',
      isApproved: map['isApproved'] ?? false,
      isQuizPassed: map['isQuizPassed'] ?? false,
      isDeclined: map['isDeclined'] ?? false,
      failedAttempts: map['failedAttempts'] ?? 0,
      quizPassedAt: map['quizPassedAt'],
      category: DesignCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => DesignCategory.homeDecor,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'qualification': qualification,
      'isApproved': isApproved,
      'isQuizPassed': isQuizPassed,
      'isDeclined': isDeclined,
      'quizPassedAt': quizPassedAt,
      'category': category.name,
      'failedAttempts': failedAttempts
    };
  }
}
