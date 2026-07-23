import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        debugPrint('CRITICAL: Firestore index required. Create it here: ${e.message}');
        throw 'A required Firestore index is missing. Please check the logs or create it using the link: ${e.message}';
      }
      throw 'Firestore Error [${e.code}]: ${e.message}';
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
