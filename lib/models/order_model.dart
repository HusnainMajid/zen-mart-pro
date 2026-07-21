import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String vendorId;
  final String shopName;
  final String? riderId;
  final String? riderName;
  final String paymentMethod;
  final double total;
  final String status; // pending, confirmed, processing, shipped, out_for_delivery, delivered, cancelled
  final DateTime orderTime;
  final DateTime? deliveryTime;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.vendorId,
    required this.shopName,
    this.riderId,
    this.riderName,
    required this.paymentMethod,
    required this.total,
    required this.status,
    required this.orderTime,
    this.deliveryTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'vendorId': vendorId,
      'shopName': shopName,
      'riderId': riderId,
      'riderName': riderName,
      'paymentMethod': paymentMethod,
      'total': total,
      'status': status,
      'orderTime': Timestamp.fromDate(orderTime),
      'deliveryTime': deliveryTime != null ? Timestamp.fromDate(deliveryTime!) : null,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      orderNumber: map['orderNumber'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      vendorId: map['vendorId'] ?? '',
      shopName: map['shopName'] ?? '',
      riderId: map['riderId'],
      riderName: map['riderName'],
      paymentMethod: map['paymentMethod'] ?? '',
      total: (map['total'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      orderTime: (map['orderTime'] as Timestamp).toDate(),
      deliveryTime: map['deliveryTime'] != null ? (map['deliveryTime'] as Timestamp).toDate() : null,
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? vendorId,
    String? shopName,
    String? riderId,
    String? riderName,
    String? paymentMethod,
    double? total,
    String? status,
    DateTime? orderTime,
    DateTime? deliveryTime,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      vendorId: vendorId ?? this.vendorId,
      shopName: shopName ?? this.shopName,
      riderId: riderId ?? this.riderId,
      riderName: riderName ?? this.riderName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      total: total ?? this.total,
      status: status ?? this.status,
      orderTime: orderTime ?? this.orderTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
    );
  }
}
