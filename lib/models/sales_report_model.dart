import 'package:cloud_firestore/cloud_firestore.dart';

class SalesReportModel {
  final DateTime date;
  final double totalRevenue;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final List<Map<String, dynamic>> bestSellingProducts;

  SalesReportModel({
    required this.date,
    required this.totalRevenue,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.bestSellingProducts,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'bestSellingProducts': bestSellingProducts,
    };
  }

  factory SalesReportModel.fromMap(Map<String, dynamic> map) {
    return SalesReportModel(
      date: (map['date'] as Timestamp).toDate(),
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      totalOrders: map['totalOrders'] ?? 0,
      completedOrders: map['completedOrders'] ?? 0,
      cancelledOrders: map['cancelledOrders'] ?? 0,
      bestSellingProducts: List<Map<String, dynamic>>.from(map['bestSellingProducts'] ?? []),
    );
  }

  SalesReportModel copyWith({
    DateTime? date,
    double? totalRevenue,
    int? totalOrders,
    int? completedOrders,
    int? cancelledOrders,
    List<Map<String, dynamic>>? bestSellingProducts,
  }) {
    return SalesReportModel(
      date: date ?? this.date,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalOrders: totalOrders ?? this.totalOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      bestSellingProducts: bestSellingProducts ?? this.bestSellingProducts,
    );
  }
}
