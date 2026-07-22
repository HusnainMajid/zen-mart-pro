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
  final String? barcode;
  final double? weight;
  final String? unit;
  final int stock;
  final int minStockAlert;
  final String status;
  final String imageUrl;
  final List<String> images;
  final bool isFeatured;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    this.barcode,
    this.weight,
    this.unit,
    required this.stock,
    required this.minStockAlert,
    required this.status,
    required this.imageUrl,
    required this.images,
    required this.isFeatured,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
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
      'barcode': barcode,
      'weight': weight,
      'unit': unit,
      'stock': stock,
      'minStockAlert': minStockAlert,
      'status': status,
      'imageUrl': imageUrl,
      'images': images,
      'isFeatured': isFeatured,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
      barcode: map['barcode'],
      weight: map['weight'] != null ? (map['weight']).toDouble() : null,
      unit: map['unit'],
      stock: (map['stock'] ?? 0).toInt(),
      minStockAlert: (map['minStockAlert'] ?? 0).toInt(),
      status: map['status'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      isFeatured: map['isFeatured'] ?? false,
      isAvailable: map['isAvailable'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
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
    String? barcode,
    double? weight,
    String? unit,
    int? stock,
    int? minStockAlert,
    String? status,
    String? imageUrl,
    List<String>? images,
    bool? isFeatured,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      barcode: barcode ?? this.barcode,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      isFeatured: isFeatured ?? this.isFeatured,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
