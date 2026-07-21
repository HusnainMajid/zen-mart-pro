import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  final String id;
  final String name;
  final String address;
  final String description;
  final String contact;
  final String banner;
  final String logo;
  final String ownerId;
  final String status; // e.g., 'active', 'inactive', 'pending'
  final DateTime createdAt;

  ShopModel({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.contact,
    required this.banner,
    required this.logo,
    required this.ownerId,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'contact': contact,
      'banner': banner,
      'logo': logo,
      'ownerId': ownerId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ShopModel.fromMap(Map<String, dynamic> map) {
    return ShopModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      description: map['description'] ?? '',
      contact: map['contact'] ?? '',
      banner: map['banner'] ?? '',
      logo: map['logo'] ?? '',
      ownerId: map['ownerId'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  ShopModel copyWith({
    String? id,
    String? name,
    String? address,
    String? description,
    String? contact,
    String? banner,
    String? logo,
    String? ownerId,
    String? status,
    DateTime? createdAt,
  }) {
    return ShopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      contact: contact ?? this.contact,
      banner: banner ?? this.banner,
      logo: logo ?? this.logo,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
