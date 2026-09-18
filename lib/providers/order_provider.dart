// File: lib/providers/order_provider.dart
// Manages order state: placing orders, tracking, listing

import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/address_model.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  OrderModel? _currentOrder;
  bool _isLoading = false;
  bool _isPlacing = false;
  String? _error;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  OrderModel? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  bool get isPlacing => _isPlacing;
  String? get error => _error;

  /// Get active orders (not delivered or cancelled)
  List<OrderModel> get activeOrders => _orders
      .where((o) =>
          o.status != 'delivered' && o.status != 'cancelled')
      .toList();

  /// Get past orders (delivered or cancelled)
  List<OrderModel> get pastOrders => _orders
      .where((o) => o.status == 'delivered' || o.status == 'cancelled')
      .toList();

  /// Start listening to user's orders (real-time)
  void listenToOrders(String userId) {
    _isLoading = true;
    notifyListeners();

    _orderService.getUserOrders(userId).listen((orders) {
      _orders = orders;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Start listening to a specific order (for tracking screen)
  void listenToOrder(String orderId) {
    _orderService.getOrderStream(orderId).listen((order) {
      _currentOrder = order;
      notifyListeners();
    });
  }

  /// Place a new order
  Future<bool> placeOrder({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required List<CartItem> items,
    required AddressModel deliveryAddress,
    required String paymentMethod,
  }) async {
    _isPlacing = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _orderService.placeOrder(
        userId: userId,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: items,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );
      _currentOrder = order;
      _isPlacing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to place order. Please try again.';
      _isPlacing = false;
      notifyListeners();
      return false;
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(String orderId) async {
    try {
      final success = await _orderService.cancelOrder(orderId);
      return success;
    } catch (e) {
      _error = 'Failed to cancel order.';
      notifyListeners();
      return false;
    }
  }

  /// Update order status (admin)
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      return true;
    } catch (e) {
      _error = 'Failed to update order status.';
      notifyListeners();
      return false;
    }
  }

  /// Listen to all orders (admin)
  void listenToAllOrders() {
    _isLoading = true;
    notifyListeners();

    _orderService.getAllOrders().listen((orders) {
      _orders = orders;
      _isLoading = false;
      notifyListeners();
    });
  }
}
