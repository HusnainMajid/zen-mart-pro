import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String? shopId;
  final int displayOrder;
  final String status; // 'active', 'inactive'
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.shopId,
    this.displayOrder = 0,
    this.status = 'active',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'shopId': shopId,
      'displayOrder': displayOrder,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      shopId: map['shopId'],
      displayOrder: (map['displayOrder'] ?? 0).toInt(),
      status: map['status'] ?? 'active',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? shopId,
    int? displayOrder,
    String? status,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shopId: shopId ?? this.shopId,
      displayOrder: displayOrder ?? this.displayOrder,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
