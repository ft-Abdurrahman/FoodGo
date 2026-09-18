// File: lib/screens/admin/admin_orders_screen.dart
// Admin screen to view all orders and update their statuses

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('All Orders')),
      body: orderProvider.isLoading
          ? const LoadingIndicator()
          : orderProvider.orders.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long,
                  title: 'No orders yet',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orderProvider.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderProvider.orders[index];
                    return _buildOrderCard(context, order, orderProvider);
                  },
                ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order,
      OrderProvider orderProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  '#${order.orderId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Details
            Text(
              order.restaurantName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              '${order.items.length} items • ${AppHelpers.formatPrice(order.totalAmount)}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              AppHelpers.formatDateTime(order.createdAt),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            // Status update dropdown
            if (order.status != 'delivered' &&
                order.status != 'cancelled')
              Row(
                children: [
                  const Text(
                    'Update Status: ',
                    style: TextStyle(fontSize: 13),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      value: order.status,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: AppConstants.statusPlaced,
                          child: Text('Placed'),
                        ),
                        DropdownMenuItem(
                          value: AppConstants.statusConfirmed,
                          child: Text('Confirmed'),
                        ),
                        DropdownMenuItem(
                          value: AppConstants.statusPreparing,
                          child: Text('Preparing'),
                        ),
                        DropdownMenuItem(
                          value: AppConstants.statusOutForDelivery,
                          child: Text('Out for Delivery'),
                        ),
                        DropdownMenuItem(
                          value: AppConstants.statusDelivered,
                          child: Text('Delivered'),
                        ),
                        DropdownMenuItem(
                          value: AppConstants.statusCancelled,
                          child: Text(
                            'Cancelled',
                            style:
                                TextStyle(color: AppTheme.errorColor),
                          ),
                        ),
                      ],
                      onChanged: (newStatus) async {
                        if (newStatus != null) {
                          await orderProvider.updateOrderStatus(
                              order.id, newStatus);
                          if (context.mounted) {
                            AppHelpers.showSnackBar(
                              context,
                              'Order status updated',
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'placed':
        return Colors.blue;
      case 'confirmed':
        return Colors.indigo;
      case 'preparing':
        return Colors.orange;
      case 'outForDelivery':
        return Colors.purple;
      case 'delivered':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }
}
