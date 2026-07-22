import 'product_model.dart';
import 'order_model.dart';

class VendorDashboardStats {
  final int totalProducts;
  final int totalCategories;
  final int totalOrders;
  final int pendingOrders;
  final double revenueToday;
  final double revenueMonth;
  final List<ProductModel> lowStockProducts;
  final List<OrderModel> recentOrders;

  VendorDashboardStats({
    required this.totalProducts,
    required this.totalCategories,
    required this.totalOrders,
    required this.pendingOrders,
    required this.revenueToday,
    required this.revenueMonth,
    required this.lowStockProducts,
    required this.recentOrders,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalProducts': totalProducts,
      'totalCategories': totalCategories,
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'revenueToday': revenueToday,
      'revenueMonth': revenueMonth,
      'lowStockProducts': lowStockProducts.map((x) => x.toMap()).toList(),
      'recentOrders': recentOrders.map((x) => x.toMap()).toList(),
    };
  }

  factory VendorDashboardStats.fromMap(Map<String, dynamic> map) {
    return VendorDashboardStats(
      totalProducts: (map['totalProducts'] ?? 0).toInt(),
      totalCategories: (map['totalCategories'] ?? 0).toInt(),
      totalOrders: (map['totalOrders'] ?? 0).toInt(),
      pendingOrders: (map['pendingOrders'] ?? 0).toInt(),
      revenueToday: (map['revenueToday'] ?? 0.0).toDouble(),
      revenueMonth: (map['revenueMonth'] ?? 0.0).toDouble(),
      lowStockProducts: List<ProductModel>.from(
        (map['lowStockProducts'] ?? []).map((x) => ProductModel.fromMap(x)),
      ),
      recentOrders: List<OrderModel>.from(
        (map['recentOrders'] ?? []).map((x) => OrderModel.fromMap(x)),
      ),
    );
  }
}
