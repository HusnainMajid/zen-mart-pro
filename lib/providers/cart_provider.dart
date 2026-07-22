import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.total);
  double get tax => subtotal * 0.05; // 5% tax example
  double get discount => 0.0; // Implement discount logic if needed
  double get total => subtotal + tax - discount;

  CartProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    _cartService.getCartItems().listen((items) {
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

  Future<void> addToCart(CartItemModel item) async {
    try {
      _error = null;
      await _cartService.addToCart(item);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(productId);
        return;
      }
      _error = null;
      final index = _items.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        final updatedItem = _items[index].copyWith(
          quantity: newQuantity,
          total: _items[index].price * newQuantity,
        );
        await _cartService.updateCartItem(updatedItem);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      _error = null;
      await _cartService.removeFromCart(productId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      _error = null;
      await _cartService.clearCart();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
