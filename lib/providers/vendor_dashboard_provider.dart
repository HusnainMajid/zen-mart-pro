import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/vendor_dashboard_stats.dart';
import '../models/order_model.dart';
import '../services/vendor_product_service.dart';
import '../services/vendor_category_service.dart';

class VendorDashboardProvider with ChangeNotifier {
  final VendorProductService _productService = VendorProductService();
  final VendorCategoryService _categoryService = VendorCategoryService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VendorDashboardStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  VendorDashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches totals and revenue statistics for the vendor dashboard.
  Future<void> fetchDashboardData(String vendorId, String shopId) async {
    _setLoading(true);
    try {
      // 1. Fetch products to get total count and low stock items
      final products = await _productService.getShopProducts(shopId);
      final totalProducts = products.length;

      // 2. Fetch total categories for the shop
      final categories = await _categoryService.getShopCategories(shopId);
      final totalCategories = categories.length;

      // 3. Fetch orders for this vendor
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .get();
      
      final orders = ordersSnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList();

      final totalOrders = orders.length;
      final pendingOrders = orders.where((o) => o.status == 'pending').length;

      // 4. Calculate revenue (Daily and Monthly) from delivered orders
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

      // 5. Filter low stock products
      final lowStockProducts = products
          .where((p) => p.stock <= p.minStockAlert)
          .toList();

      // 6. Get 5 most recent orders
      orders.sort((a, b) => b.orderTime.compareTo(a.orderTime));
      final recentOrders = orders.take(5).toList();

      _stats = VendorDashboardStats(
        totalProducts: totalProducts,
        totalCategories: totalCategories,
        totalOrders: totalOrders,
        pendingOrders: pendingOrders,
        revenueToday: revenueToday,
        revenueMonth: revenueMonth,
        lowStockProducts: lowStockProducts,
        recentOrders: recentOrders,
      );
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
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
