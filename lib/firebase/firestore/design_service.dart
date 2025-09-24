import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/models/design_model.dart';
import 'package:design_hub/models/review_model.dart';

class DesignService {
  final CollectionReference _designsRef =
      FirebaseFirestore.instance.collection('designs');

  // Store a new design
  Future<void> addDesign(DesignModel design) async {
    try {
      if (design.id.isNotEmpty) {
        // This is an update
        await _designsRef
            .doc(design.id)
            .set(design.toMap(), SetOptions(merge: true));
      } else {
        // This is a new design (create new doc with ID)
        final docRef = _designsRef.doc();
        final designWithId = DesignModel(
          id: docRef.id,
          name: design.name,
          caption: design.caption,
          images: design.images,
          designerId: design.designerId,
          postedAt: design.postedAt,
          likedBy: design.likedBy,
          reviewsCount: design.reviewsCount,
          category: design.category,
          isDeleted: design.isDeleted,
        );
        await docRef.set(designWithId.toMap());
      }
    } catch (e) {
      throw Exception('Failed to save design: $e');
    }
  }

  // Get all designs where isDeleted is false (one-time fetch)
  Future<List<DesignModel>> getAllDesigns() async {
    try {
      final querySnapshot =
          await _designsRef.where('isDeleted', isEqualTo: false).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DesignModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch designs: $e');
    }
  }

  // Stream of designs for a specific user (designer)
  Stream<List<DesignModel>> getDesignsByDesigner(String designerId) {
    try {
      return _designsRef
          .where('designerId', isEqualTo: designerId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('postedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DesignModel.fromMap(data, doc.id);
              }).toList());
    } catch (e) {
      throw Exception('Failed to stream designs: $e');
    }
  }

  // Get a single design by ID
  Future<DesignModel?> getDesignById(String designId) async {
    try {
      final docSnapshot = await _designsRef.doc(designId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return DesignModel.fromMap(data, docSnapshot.id);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch design with ID $designId: $e');
    }
  }

  // Add a review to a design
  Future<void> addReview(String designId, ReviewModel review) async {
    try {
      final reviewsRef = _designsRef.doc(designId).collection('reviews');

      // If the review has no ID, auto-generate it
      final docRef = reviewsRef.doc();
      final reviewWithId = ReviewModel(
        id: docRef.id,
        content: review.content,
        reviewerId: review.reviewerId,
        reviewedAt: review.reviewedAt,
      );
      await docRef.set(reviewWithId.toMap());
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // Get all reviews for a design
  Future<List<ReviewModel>> getReviews(String designId) async {
    try {
      final reviewsRef = _designsRef.doc(designId).collection('reviews');
      final querySnapshot =
          await reviewsRef.orderBy('reviewedAt', descending: true).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ReviewModel.fromMap(data, id: doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }
}
