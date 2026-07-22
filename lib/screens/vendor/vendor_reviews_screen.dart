import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_review_provider.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../models/review_model.dart';
import '../../utils/snackbar_helper.dart';

class VendorReviewsScreen extends StatefulWidget {
  const VendorReviewsScreen({super.key});

  @override
  State<VendorReviewsScreen> createState() => _VendorReviewsScreenState();
}

class _VendorReviewsScreenState extends State<VendorReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReviews());
  }

  void _loadReviews() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null && user.shopId != null) {
      context.read<VendorReviewProvider>().fetchReviews(user.shopId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<VendorReviewProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Reviews'),
      ),
      body: reviewProvider.isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: () async => _loadReviews(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRatingOverview(reviewProvider),
                    const SizedBox(height: 24),
                    const Text(
                      'All Reviews',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (reviewProvider.reviews.isEmpty)
                      const EmptyStateWidget(
                        message: 'No reviews yet',
                        icon: Icons.rate_review_outlined,
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviewProvider.reviews.length,
                        itemBuilder: (context, index) {
                          final ReviewModel review = reviewProvider.reviews[index];
                          return _buildReviewCard(review);
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRatingOverview(VendorReviewProvider provider) {
    final counts = provider.ratingCounts;
    final totalReviews = provider.reviews.length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  provider.averageRating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < provider.averageRating.round() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('$totalReviews reviews', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [5, 4, 3, 2, 1].map((star) {
                  final count = counts[star] ?? 0;
                  final percentage = totalReviews == 0 ? 0.0 : count / totalReviews;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        Text('$star', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 20,
                          child: Text('$count', style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.customerName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(review.createdAt),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(review.comment),
            if (review.reply != null && review.reply!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Reply:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Text(review.reply!),
                  ],
                ),
              ),
            ] else
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _showReplyDialog(review),
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('Reply'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showReplyDialog(ReviewModel review) {
    final TextEditingController replyController = TextEditingController();
    final navigator = Navigator.of(context);
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Review'),
        content: TextField(
          controller: replyController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Type your reply here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (replyController.text.trim().isEmpty) return;
              
              final user = scaffoldContext.read<AuthProvider>().currentUser;
              final success = await scaffoldContext.read<VendorReviewProvider>().replyToReview(
                    review.id,
                    replyController.text.trim(),
                    user!.shopId!,
                  );
              
              if (!scaffoldContext.mounted) return;
              navigator.pop();
              
              if (success) {
                SnackBarHelper.showSuccess(scaffoldContext, 'Reply posted successfully');
              } else {
                SnackBarHelper.showError(
                  scaffoldContext,
                  scaffoldContext.read<VendorReviewProvider>().errorMessage ?? 'Failed to post reply',
                );
              }
            },
            child: const Text('Post Reply'),
          ),
        ],
      ),
    );
  }
}
