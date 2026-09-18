// File: lib/screens/orders/order_tracking_screen.dart
// Real-time order tracking with status updates from Firestore

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/order_status_widget.dart';
import '../../widgets/custom_button.dart';
import '../../utils/helpers.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    // Start listening to order updates in real-time
    context.read<OrderProvider>().listenToOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final order = orderProvider.currentOrder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        actions: [
          if (order != null && order.status == 'placed')
            TextButton(
              onPressed: () => _cancelOrder(context, orderProvider),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
        ],
      ),
      body: order == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderId}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Placed on ${AppHelpers.formatDateTime(order.createdAt)}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Order status tracker
                  const Text(
                    'Order Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: OrderStatusWidget(
                      currentStep: order.statusIndex,
                      isCancelled: order.status == 'cancelled',
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Restaurant info
                  const Text(
                    'Restaurant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.restaurant,
                          color: AppTheme.primaryColor),
                      title: Text(order.restaurantName),
                      subtitle: Text(order.items.length > 1
                          ? '${order.items.length} items'
                          : '${order.items.length} item'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Order items
                  const Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: order.items.map((item) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.name} × ${item.quantity}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  AppHelpers.formatPrice(item.totalPrice),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                            Text(AppHelpers.formatPrice(order.subtotal)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Delivery Fee',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                            Text(
                              order.deliveryFee == 0
                                  ? 'FREE'
                                  : AppHelpers.formatPrice(
                                      order.deliveryFee),
                              style: TextStyle(
                                color: order.deliveryFee == 0
                                    ? AppTheme.successColor
                                    : AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              AppHelpers.formatPrice(order.totalAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Delivery address
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on,
                          color: AppTheme.primaryColor),
                      title: Text(
                        order.deliveryAddress['label'] ?? 'Address',
                        style:
                            const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${order.deliveryAddress['street']}, ${order.deliveryAddress['city']}, ${order.deliveryAddress['state']} - ${order.deliveryAddress['pincode']}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Payment method
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.payment,
                          color: AppTheme.primaryColor),
                      title: const Text('Payment'),
                      subtitle: Text(order.paymentMethod),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Future<void> _cancelOrder(
      BuildContext context, OrderProvider orderProvider) async {
    final confirmed = await AppHelpers.showConfirmDialog(
      context,
      title: 'Cancel Order',
      message: 'Are you sure you want to cancel this order?',
      confirmText: 'Cancel Order',
      isDestructive: true,
    );

    if (confirmed) {
      final success =
          await orderProvider.cancelOrder(widget.orderId);
      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          success ? 'Order cancelled' : 'Failed to cancel order',
          isError: !success,
        );
      }
    }
  }
}
