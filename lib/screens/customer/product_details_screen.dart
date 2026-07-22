import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../models/product_model.dart';
import '../../models/cart_item_model.dart';
import '../../models/wishlist_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/vendor_review_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/snackbar_helper.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorReviewProvider>().fetchReviews(widget.product.shopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final isInWishlist = wishlistProvider.isInWishlist(widget.product.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Carousel Header
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isInWishlist ? Colors.red : Colors.black,
                  ),
                  onPressed: () => _toggleWishlist(wishlistProvider),
                ),
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: widget.product.images.isNotEmpty ? widget.product.images.length : 1,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final imageUrl = widget.product.images.isNotEmpty ? widget.product.images[index] : widget.product.imageUrl;
                      return CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => const Icon(Icons.image, size: 50),
                      );
                    },
                  ),
                  if (widget.product.images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.product.images.asMap().entries.map((entry) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == entry.key ? Colors.blue : Colors.white70,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.product.categoryName,
                          style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        widget.product.status.toUpperCase(),
                        style: TextStyle(
                          color: widget.product.isAvailable ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(widget.product.discountPrice ?? widget.product.price),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      if (widget.product.discountPrice != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          CurrencyFormatter.format(widget.product.price),
                          style: const TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(((widget.product.price - widget.product.discountPrice!) / widget.product.price) * 100).round()}% OFF',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Vendor Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.store, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sold by', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(
                                widget.product.shopName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {}, // Navigate to shop details
                          child: const Text('Visit Shop'),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Customer Reviews',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildReviewsSection(),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(cartProvider),
    );
  }

  Widget _buildReviewsSection() {
    return Consumer<VendorReviewProvider>(
      builder: (context, reviewProvider, _) {
        if (reviewProvider.isLoading) {
          return const Skeletonizer(
            child: Column(
              children: [
                ListTile(title: Text('Loading Review...'), subtitle: Text('Comment...'), leading: CircleAvatar()),
                ListTile(title: Text('Loading Review...'), subtitle: Text('Comment...'), leading: CircleAvatar()),
              ],
            ),
          );
        }

        if (reviewProvider.reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No reviews yet for this shop.')),
          );
        }

        return Column(
          children: reviewProvider.reviews.take(3).map((review) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(review.customerName[0].toUpperCase()),
              ),
              title: Row(
                children: [
                  Text(review.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
              subtitle: Text(review.comment),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBottomBar(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _addToCart(cartProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(CartProvider cartProvider) async {
    final cartItem = CartItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: widget.product.id,
      name: widget.product.name,
      price: widget.product.discountPrice ?? widget.product.price,
      imageUrl: widget.product.imageUrl,
      quantity: _quantity,
      total: (widget.product.discountPrice ?? widget.product.price) * _quantity,
      shopId: widget.product.shopId,
    );

    try {
      await cartProvider.addToCart(cartItem);
      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Added to cart successfully!');
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Failed to add to cart: $e');
      }
    }
  }

  void _toggleWishlist(WishlistProvider wishlistProvider) async {
    final wishlistItem = WishlistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: widget.product.id,
      name: widget.product.name,
      price: widget.product.discountPrice ?? widget.product.price,
      imageUrl: widget.product.imageUrl,
      shopId: widget.product.shopId,
      addedAt: DateTime.now(),
    );

    try {
      await wishlistProvider.toggleWishlist(wishlistItem);
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Failed to update wishlist: $e');
      }
    }
  }
}
