// File: lib/models/order_model.dart
// Represents an order stored in Firestore orders collection

import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_model.dart';

class OrderModel {
  final String id;
  final String orderId; // Display ID like "FOOD1024"
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<CartItem> items;
  final Map<String, dynamic> deliveryAddress;
  final String paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double totalAmount;
  final String status; // placed, confirmed, preparing, outForDelivery, delivered, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0.0,
    required this.totalAmount,
    this.status = 'placed',
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsList = (data['items'] as List<dynamic>?)
            ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
            .toList() ??
        [];

    return OrderModel(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      userId: data['userId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      items: itemsList,
      deliveryAddress: Map<String, dynamic>.from(data['deliveryAddress'] ?? {}),
      paymentMethod: data['paymentMethod'] ?? '',
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'placed',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((item) => item.toMap()).toList(),
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Get human-readable status label
  String get statusLabel {
    switch (status) {
      case 'placed':
        return 'Order Placed';
      case 'confirmed':
        return 'Restaurant Confirmed';
      case 'preparing':
        return 'Preparing Food';
      case 'outForDelivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Get status color for UI indicators
  int get statusIndex {
    switch (status) {
      case 'placed':
        return 0;
      case 'confirmed':
        return 1;
      case 'preparing':
        return 2;
      case 'outForDelivery':
        return 3;
      case 'delivered':
        return 4;
      case 'cancelled':
        return -1;
      default:
        return 0;
    }
  }
}
