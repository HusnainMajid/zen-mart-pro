import 'package:cloud_firestore/cloud_firestore.dart';

class ShopBannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final bool isActive;
  final DateTime createdAt;

  ShopBannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ShopBannerModel.fromMap(Map<String, dynamic> map) {
    return ShopBannerModel(
      id: map['id'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  ShopBannerModel copyWith({
    String? id,
    String? imageUrl,
    String? title,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ShopBannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
