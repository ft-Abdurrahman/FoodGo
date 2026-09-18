// File: lib/models/cart_model.dart
// Represents a single item in the shopping cart (not persisted to Firestore)

class CartItem {
  final String foodId;
  final String restaurantId;
  final String restaurantName;
  final String name;
  final String image;
  final double price;
  int quantity;

  CartItem({
    required this.foodId,
    required this.restaurantId,
    required this.restaurantName,
    required this.name,
    required this.image,
    required this.price,
    this.quantity = 1,
  });

  /// Total price for this item (price × quantity)
  double get totalPrice => price * quantity;

  /// Convert to Firestore-compatible map (for order snapshots)
  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      foodId: map['foodId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }
}
