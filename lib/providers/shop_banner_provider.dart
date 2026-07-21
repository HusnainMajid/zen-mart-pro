import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/shop_banner_model.dart';
import '../services/shop_banner_service.dart';
import '../services/storage_service.dart';

class ShopBannerProvider with ChangeNotifier {
  final ShopBannerService _bannerService = ShopBannerService();
  final StorageService _storageService = StorageService();

  List<ShopBannerModel> _banners = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ShopBannerModel> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches all banners.
  Future<void> fetchBanners() async {
    _setLoading(true);
    try {
      _banners = await _bannerService.getAllBanners();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Uploads a new banner.
  Future<bool> uploadBanner({
    required String title,
    required File imageFile,
  }) async {
    _setLoading(true);
    try {
      final id = const Uuid().v4();
      final imageUrl = await _storageService.uploadImage(imageFile, 'banners/$id');

      final banner = ShopBannerModel(
        id: id,
        title: title,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await _bannerService.addBanner(banner);
      await fetchBanners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a banner.
  Future<bool> deleteBanner(ShopBannerModel banner) async {
    _setLoading(true);
    try {
      await _storageService.deleteFile(banner.imageUrl);
      await _bannerService.deleteBanner(banner.id);
      await fetchBanners();
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
