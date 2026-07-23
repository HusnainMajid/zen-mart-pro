import 'dart:async';
import 'package:flutter/material.dart';
import '../models/vendor_dashboard_stats.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../services/vendor_product_service.dart';
import '../services/vendor_category_service.dart';
import '../services/vendor_order_service.dart';

class VendorDashboardProvider with ChangeNotifier {
  final VendorProductService _productService = VendorProductService();
  final VendorCategoryService _categoryService = VendorCategoryService();
  final VendorOrderService _orderService = VendorOrderService();

  VendorDashboardStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  VendorDashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches dashboard data once (alternative to listening).
  Future<void> fetchDashboardData(String vendorId, String shopId) async {
    _setLoading(true);
    try {
      final orders = await _orderService.getShopOrdersOnce(shopId);
      final products = await _productService.getShopProducts(shopId);
      final categories = await _categoryService.getShopCategories(shopId);
      
      _calculateStats(orders, products, categories.length);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  StreamSubscription? _orderSubscription;

  /// Starts listening to dashboard data changes
  void listenToDashboardData(String vendorId, String shopId) {
    debugPrint('VendorDashboardProvider: Starting dashboard listener for vendor: $vendorId, shop: $shopId');
    _setLoading(true);
    
    // Cancel any existing subscription
    _orderSubscription?.cancel();
    
    _orderSubscription = _orderService.getShopOrdersStream(shopId).listen((orders) async {
      debugPrint('VendorDashboardProvider: Received ${orders.length} orders');
      // Fetch products and categories once (or could also stream them)
      final products = await _productService.getShopProducts(shopId);
      final categories = await _categoryService.getShopCategories(shopId);
      
      _calculateStats(orders, products, categories.length);
      _setLoading(false);
    }, onError: (e) {
      debugPrint('VendorDashboardProvider: Stream Error: $e');
      _errorMessage = e.toString();
      _setLoading(false);
    });
  }

  void reset() {
    _orderSubscription?.cancel();
    _orderSubscription = null;
    _stats = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void _calculateStats(List<OrderModel> orders, List<ProductModel> products, int totalCategories) {
    final totalOrders = orders.length;
    final pendingOrders = orders.where((o) => o.status == 'pending').length;

    double revenueToday = 0;
    double revenueMonth = 0;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);

    for (var order in orders) {
      if (order.status == 'delivered') {
        if (order.orderTime.isAfter(todayStart)) {
          revenueToday += order.total;
        }
        if (order.orderTime.isAfter(monthStart)) {
          revenueMonth += order.total;
        }
      }
    }

    final lowStockProducts = products
        .where((p) => p.stock <= p.minStockAlert)
        .toList();

    orders.sort((a, b) => b.orderTime.compareTo(a.orderTime));
    final recentOrders = orders.take(5).toList();

    _stats = VendorDashboardStats(
      totalProducts: products.length,
      totalCategories: totalCategories,
      totalOrders: totalOrders,
      pendingOrders: pendingOrders,
      revenueToday: revenueToday,
      revenueMonth: revenueMonth,
      lowStockProducts: lowStockProducts,
      recentOrders: recentOrders,
    );
    notifyListeners();
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
