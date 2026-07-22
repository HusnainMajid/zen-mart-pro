import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String customerId;
  final String customerName;
  final String shopId;
  final double rating;
  final String comment;
  final String? reply;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.shopId,
    required this.rating,
    required this.comment,
    this.reply,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'shopId': shopId,
      'rating': rating,
      'comment': comment,
      'reply': reply,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      shopId: map['shopId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      reply: map['reply'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  ReviewModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? shopId,
    double? rating,
    String? comment,
    String? reply,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      shopId: shopId ?? this.shopId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      reply: reply ?? this.reply,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
