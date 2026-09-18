// File: lib/services/order_service.dart
// Handles order creation, status updates, and real-time order tracking

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/address_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Place a new order
  /// Creates order document in Firestore and returns the order
  Future<OrderModel> placeOrder({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required List<CartItem> items,
    required AddressModel deliveryAddress,
    required String paymentMethod,
  }) async {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final deliveryFee =
        subtotal >= AppConstants.freeDeliveryAbove ? 0.0 : AppConstants.deliveryFee;
    final totalAmount = subtotal + deliveryFee;

    final orderId = AppHelpers.generateOrderId();
    final now = DateTime.now();

    final order = OrderModel(
      id: '', // Will be set by Firestore
      orderId: orderId,
      userId: userId,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      items: items,
      deliveryAddress: deliveryAddress.toFirestore(),
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      totalAmount: totalAmount,
      status: AppConstants.statusPlaced,
      createdAt: now,
      updatedAt: now,
    );

    final docRef = await _db
        .collection(AppConstants.ordersCollection)
        .add(order.toFirestore());

    return order.copyWith(id: docRef.id);
  }

  /// Stream orders for a specific user (real-time updates)
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _db
        .collection(AppConstants.ordersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }

  /// Stream a single order (for real-time tracking)
  Stream<OrderModel?> getOrderStream(String orderId) {
    return _db
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.exists ? OrderModel.fromFirestore(doc) : null);
  }

  /// Get all orders (admin)
  Stream<List<OrderModel>> getAllOrders() {
    return _db
        .collection(AppConstants.ordersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }

  /// Update order status (admin operation)
  /// Cloud Functions should handle sending FCM notifications on status change
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp,
    });
  }

  /// Cancel an order (only if status is 'placed')
  Future<bool> cancelOrder(String orderId) async {
    try {
      final doc = await _db
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .get();

      if (!doc.exists) return false;

      final status = doc.data()?['status'] as String;
      if (status != AppConstants.statusPlaced) return false;

      await _db
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .update({
        'status': AppConstants.statusCancelled,
        'updatedAt': FieldValue.serverTimestamp,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
