import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

/// Service to handle vendor-specific review operations
class VendorReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reviews';

  /// Fetch all reviews for a specific shop
  Future<List<ReviewModel>> getShopReviews(String shopId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Failed to fetch shop reviews: ${e.toString()}';
    }
  }

  /// Update the reply field for a specific review
  Future<void> replyToReview(String reviewId, String reply) async {
    try {
      await _firestore.collection(_collection).doc(reviewId).update({
        'reply': reply,
      });
    } catch (e) {
      throw 'Failed to reply to review: ${e.toString()}';
    }
  }
}
