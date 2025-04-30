import 'package:design_hub/models/design_model.dart';

class DesignerDetailesModel {
  final String uid;
  final String qualification;
  bool isApproved;
  bool isQuizPassed;
  final DesignCategory category;

  DesignerDetailesModel({
    required this.uid,
    required this.qualification,
    required this.category,
    required this.isApproved,
    required this.isQuizPassed,
  });

  factory DesignerDetailesModel.fromMap(Map<String, dynamic> map) {
    return DesignerDetailesModel(
      uid: map['uid'] ?? '',
      qualification: map['qualification'] ?? '',
      isApproved: map['isApproved'] ?? false,
      isQuizPassed: map['isQuizPassed'] ?? false,
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
      'category': category.name,
    };
  }
}
