import 'package:cloud_firestore/cloud_firestore.dart';

class RiderModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String status; // e.g., 'active', 'inactive', 'on_delivery'
  final DateTime createdAt;

  RiderModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RiderModel.fromMap(Map<String, dynamic> map) {
    return RiderModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      status: map['status'] ?? 'active',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  RiderModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? status,
    DateTime? createdAt,
  }) {
    return RiderModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
