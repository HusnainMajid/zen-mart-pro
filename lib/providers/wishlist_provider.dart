import 'package:flutter/material.dart';
import '../models/wishlist_model.dart';
import '../models/cart_item_model.dart';
import '../services/wishlist_service.dart';
import '../services/cart_service.dart';

class WishlistProvider with ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();
  final CartService _cartService = CartService();
  List<WishlistModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<WishlistModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WishlistProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    _wishlistService.getWishlist().listen((items) {
      _items = items;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> toggleWishlist(WishlistModel item) async {
    try {
      _error = null;
      final exists = _items.any((i) => i.productId == item.productId);
      if (exists) {
        await _wishlistService.removeFromWishlist(item.productId);
      } else {
        await _wishlistService.addToWishlist(item);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> moveToCart(WishlistModel wishlistItem) async {
    try {
      _error = null;
      final cartItem = CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: wishlistItem.productId,
        name: wishlistItem.name,
        price: wishlistItem.price,
        imageUrl: wishlistItem.imageUrl,
        quantity: 1,
        total: wishlistItem.price,
        shopId: wishlistItem.shopId,
      );
      
      await _cartService.addToCart(cartItem);
      await _wishlistService.removeFromWishlist(wishlistItem.productId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  bool isInWishlist(String productId) {
    return _items.any((item) => item.productId == productId);
  }
}
