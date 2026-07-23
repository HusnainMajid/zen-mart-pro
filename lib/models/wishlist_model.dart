import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String shopId;
  final DateTime addedAt;

  WishlistModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.shopId,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'shopId': shopId,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory WishlistModel.fromMap(Map<String, dynamic> map) {
    return WishlistModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      shopId: map['shopId'] ?? '',
      addedAt: (map['addedAt'] as Timestamp).toDate(),
    );
  }

  WishlistModel copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    String? shopId,
    DateTime? addedAt,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      shopId: shopId ?? this.shopId,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
