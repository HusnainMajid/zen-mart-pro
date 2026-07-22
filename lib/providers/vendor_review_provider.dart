import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/vendor_review_service.dart';

class VendorReviewProvider with ChangeNotifier {
  final VendorReviewService _reviewService = VendorReviewService();

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  double _averageRating = 0.0;
  Map<int, int> _ratingCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get averageRating => _averageRating;
  Map<int, int> get ratingCounts => _ratingCounts;

  /// Fetches reviews for a specific shop and calculates stats.
  Future<void> fetchReviews(String shopId) async {
    _setLoading(true);
    try {
      _reviews = await _reviewService.getShopReviews(shopId);
      _calculateStats();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _calculateStats() {
    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      _ratingCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      notifyListeners();
      return;
    }

    double totalRating = 0;
    Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (var review in _reviews) {
      totalRating += review.rating;
      int roundedRating = review.rating.round();
      if (counts.containsKey(roundedRating)) {
        counts[roundedRating] = counts[roundedRating]! + 1;
      }
    }

    _averageRating = totalRating / _reviews.length;
    _ratingCounts = counts;
    notifyListeners();
  }

  /// Replies to a specific review.
  Future<bool> replyToReview(String reviewId, String reply, String shopId) async {
    _setLoading(true);
    try {
      await _reviewService.replyToReview(reviewId, reply);
      await fetchReviews(shopId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
