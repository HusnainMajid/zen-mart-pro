class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final double total;
  final String shopId;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    required this.shopId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'total': total,
      'shopId': shopId,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      total: (map['total'] ?? 0.0).toDouble(),
      shopId: map['shopId'] ?? '',
    );
  }

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    int? quantity,
    double? total,
    String? shopId,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
      shopId: shopId ?? this.shopId,
    );
  }
}
