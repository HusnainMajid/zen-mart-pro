import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String? shopId;
  final String profileImage;
  final String status; // e.g., 'active', 'inactive', 'suspended'
  final DateTime createdAt;

  VendorModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    this.shopId,
    required this.profileImage,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'shopId': shopId,
      'profileImage': profileImage,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      shopId: map['shopId'],
      profileImage: map['profileImage'] ?? '',
      status: map['status'] ?? 'active',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  VendorModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? shopId,
    String? profileImage,
    String? status,
    DateTime? createdAt,
  }) {
    return VendorModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      shopId: shopId ?? this.shopId,
      profileImage: profileImage ?? this.profileImage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
