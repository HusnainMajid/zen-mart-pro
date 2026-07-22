import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String vendorId;
  final String shopId;
  final String shopName;
  final String? riderId;
  final String? riderName;
  final String paymentMethod;
  final double total;
  final double tax;
  final double discount;
  final String status; // pending, confirmed, processing, shipped, out_for_delivery, delivered, cancelled
  final DateTime orderTime;
  final DateTime? deliveryTime;
  final List<OrderItemModel> items;
  final String deliveryAddress;
  final String? orderNotes;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.vendorId,
    required this.shopId,
    required this.shopName,
    this.riderId,
    this.riderName,
    required this.paymentMethod,
    required this.total,
    required this.tax,
    required this.discount,
    required this.status,
    required this.orderTime,
    this.deliveryTime,
    required this.items,
    required this.deliveryAddress,
    this.orderNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'vendorId': vendorId,
      'shopId': shopId,
      'shopName': shopName,
      'riderId': riderId,
      'riderName': riderName,
      'paymentMethod': paymentMethod,
      'total': total,
      'tax': tax,
      'discount': discount,
      'status': status,
      'orderTime': Timestamp.fromDate(orderTime),
      'deliveryTime': deliveryTime != null ? Timestamp.fromDate(deliveryTime!) : null,
      'items': items.map((x) => x.toMap()).toList(),
      'deliveryAddress': deliveryAddress,
      'orderNotes': orderNotes,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      orderNumber: map['orderNumber'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      vendorId: map['vendorId'] ?? '',
      shopId: map['shopId'] ?? '',
      shopName: map['shopName'] ?? '',
      riderId: map['riderId'],
      riderName: map['riderName'],
      paymentMethod: map['paymentMethod'] ?? '',
      total: (map['total'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      orderTime: (map['orderTime'] as Timestamp).toDate(),
      deliveryTime: map['deliveryTime'] != null ? (map['deliveryTime'] as Timestamp).toDate() : null,
      items: List<OrderItemModel>.from(
        (map['items'] as List<dynamic>? ?? []).map((x) => OrderItemModel.fromMap(x as Map<String, dynamic>)),
      ),
      deliveryAddress: map['deliveryAddress'] ?? '',
      orderNotes: map['orderNotes'],
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? vendorId,
    String? shopId,
    String? shopName,
    String? riderId,
    String? riderName,
    String? paymentMethod,
    double? total,
    double? tax,
    double? discount,
    String? status,
    DateTime? orderTime,
    DateTime? deliveryTime,
    List<OrderItemModel>? items,
    String? deliveryAddress,
    String? orderNotes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      vendorId: vendorId ?? this.vendorId,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      riderId: riderId ?? this.riderId,
      riderName: riderName ?? this.riderName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      total: total ?? this.total,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      status: status ?? this.status,
      orderTime: orderTime ?? this.orderTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      orderNotes: orderNotes ?? this.orderNotes,
    );
  }
}
