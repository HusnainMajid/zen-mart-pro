import 'package:flutter/material.dart';
import '../models/shop_model.dart';
import '../services/shop_service.dart';

class ShopProvider with ChangeNotifier {
  final ShopService _shopService = ShopService();

  List<ShopModel> _shops = [];
  bool _isLoading = false;
  String? _error;

  List<ShopModel> get shops => _shops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchShops() async {
    _setLoading(true);
    _error = null;
    try {
      _shops = await _shopService.getAllShops();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addShop(ShopModel shop) async {
    _setLoading(true);
    _error = null;
    try {
      await _shopService.createShop(shop);
      await fetchShops();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateShop(ShopModel shop) async {
    _setLoading(true);
    _error = null;
    try {
      await _shopService.updateShop(shop);
      final index = _shops.indexWhere((s) => s.id == shop.id);
      if (index != -1) {
        _shops[index] = shop;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeShop(String shopId, String ownerId) async {
    _setLoading(true);
    try {
      await _shopService.deleteShop(shopId, ownerId);
      _shops.removeWhere((s) => s.id == shopId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<ShopModel?> getShopById(String shopId) async {
    _setLoading(true);
    _error = null;
    try {
      final shop = await _shopService.getShopById(shopId);
      return shop;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> assignShop(String shopId, String vendorId) async {
    _setLoading(true);
    _error = null;
    try {
      final shopIndex = _shops.indexWhere((s) => s.id == shopId);
      if (shopIndex == -1) throw 'Shop not found';
      
      final updatedShop = _shops[shopIndex].copyWith(ownerId: vendorId);
      await _shopService.updateShop(updatedShop);
      
      // Update local state
      _shops[shopIndex] = updatedShop;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
