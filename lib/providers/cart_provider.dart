// File: lib/providers/cart_provider.dart
// Manages shopping cart state: add, remove, quantity changes, totals

import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/food_model.dart';
import '../utils/constants.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  String? _restaurantId;
  String? _restaurantName;

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;

  /// Subtotal before delivery fee
  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Delivery fee (free above threshold)
  double get deliveryFee =>
      subtotal >= AppConstants.freeDeliveryAbove ? 0.0 : AppConstants.deliveryFee;

  /// Grand total
  double get total => subtotal + deliveryFee;

  /// Total number of items (sum of quantities)
  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  /// Add a food item to cart
  /// If cart has items from a different restaurant, clear first
  void addItem(FoodModel food, String restaurantName) {
    // If adding from a different restaurant, clear cart
    if (_restaurantId != null && _restaurantId != food.restaurantId) {
      clearCart();
    }

    _restaurantId = food.restaurantId;
    _restaurantName = restaurantName;

    // Check if item already in cart
    final existingIndex = _items.indexWhere((item) => item.foodId == food.id);

    if (existingIndex >= 0) {
      // Increase quantity
      _items[existingIndex].quantity++;
    } else {
      // Add new item
      _items.add(CartItem(
        foodId: food.id,
        restaurantId: food.restaurantId,
        restaurantName: restaurantName,
        name: food.name,
        image: food.image,
        price: food.price,
      ));
    }
    notifyListeners();
  }

  /// Remove an item from cart entirely
  void removeItem(String foodId) {
    _items.removeWhere((item) => item.foodId == foodId);
    // If cart is empty, clear restaurant reference
    if (_items.isEmpty) {
      _restaurantId = null;
      _restaurantName = null;
    }
    notifyListeners();
  }

  /// Increase quantity of an item
  void incrementQuantity(String foodId) {
    final index = _items.indexWhere((item) => item.foodId == foodId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  /// Decrease quantity of an item (remove if quantity reaches 0)
  void decrementQuantity(String foodId) {
    final index = _items.indexWhere((item) => item.foodId == foodId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        removeItem(foodId);
        return;
      }
      notifyListeners();
    }
  }

  /// Get quantity of a specific food item in cart
  int getQuantity(String foodId) {
    final index = _items.indexWhere((item) => item.foodId == foodId);
    return index >= 0 ? _items[index].quantity : 0;
  }

  /// Clear entire cart
  void clearCart() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    notifyListeners();
  }
}
