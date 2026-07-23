import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String shopId;
  final String shopName;
  final String vendorId;
  final String categoryId;
  final String categoryName;
  final double price;
  final double? discountPrice;
  final String sku;
  final int stock;
  final int minStockAlert;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.shopId,
    required this.shopName,
    required this.vendorId,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    this.discountPrice,
    required this.sku,
    required this.stock,
    required this.minStockAlert,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'shopId': shopId,
      'shopName': shopName,
      'vendorId': vendorId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'price': price,
      'discountPrice': discountPrice,
      'sku': sku,
      'stock': stock,
      'minStockAlert': minStockAlert,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      shopId: map['shopId'] ?? '',
      shopName: map['shopName'] ?? '',
      vendorId: map['vendorId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      discountPrice: map['discountPrice'] != null ? (map['discountPrice']).toDouble() : null,
      sku: map['sku'] ?? '',
      stock: (map['stock'] ?? 0).toInt(),
      minStockAlert: (map['minStockAlert'] ?? 5).toInt(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? shopId,
    String? shopName,
    String? vendorId,
    String? categoryId,
    String? categoryName,
    double? price,
    double? discountPrice,
    String? sku,
    int? stock,
    int? minStockAlert,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      vendorId: vendorId ?? this.vendorId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      sku: sku ?? this.sku,
      stock: stock ?? this.stock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
