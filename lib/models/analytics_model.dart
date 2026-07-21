class AnalyticsModel {
  final double totalRevenue;
  final double monthlyRevenue;
  final int dailyOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int pendingOrders;
  final List<dynamic> topShops;
  final List<dynamic> topVendors;
  final List<dynamic> topCustomers;

  AnalyticsModel({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.dailyOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.pendingOrders,
    required this.topShops,
    required this.topVendors,
    required this.topCustomers,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalRevenue': totalRevenue,
      'monthlyRevenue': monthlyRevenue,
      'dailyOrders': dailyOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'pendingOrders': pendingOrders,
      'topShops': topShops,
      'topVendors': topVendors,
      'topCustomers': topCustomers,
    };
  }

  factory AnalyticsModel.fromMap(Map<String, dynamic> map) {
    return AnalyticsModel(
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      monthlyRevenue: (map['monthlyRevenue'] ?? 0.0).toDouble(),
      dailyOrders: (map['dailyOrders'] ?? 0).toInt(),
      completedOrders: (map['completedOrders'] ?? 0).toInt(),
      cancelledOrders: (map['cancelledOrders'] ?? 0).toInt(),
      pendingOrders: (map['pendingOrders'] ?? 0).toInt(),
      topShops: List<dynamic>.from(map['topShops'] ?? []),
      topVendors: List<dynamic>.from(map['topVendors'] ?? []),
      topCustomers: List<dynamic>.from(map['topCustomers'] ?? []),
    );
  }

  AnalyticsModel copyWith({
    double? totalRevenue,
    double? monthlyRevenue,
    int? dailyOrders,
    int? completedOrders,
    int? cancelledOrders,
    int? pendingOrders,
    List<dynamic>? topShops,
    List<dynamic>? topVendors,
    List<dynamic>? topCustomers,
  }) {
    return AnalyticsModel(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      dailyOrders: dailyOrders ?? this.dailyOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      topShops: topShops ?? this.topShops,
      topVendors: topVendors ?? this.topVendors,
      topCustomers: topCustomers ?? this.topCustomers,
    );
  }
}
