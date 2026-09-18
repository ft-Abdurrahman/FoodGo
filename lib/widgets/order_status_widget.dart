// File: lib/widgets/order_status_widget.dart
// Visual order status tracker with step indicators

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OrderStatusWidget extends StatelessWidget {
  final int currentStep; // 0-4 for placed through delivered, -1 for cancelled
  final bool isCancelled;

  const OrderStatusWidget({
    super.key,
    required this.currentStep,
    this.isCancelled = false,
  });

  static const _steps = [
    {'title': 'Order Placed', 'icon': Icons.receipt_long},
    {'title': 'Confirmed', 'icon': Icons.check_circle_outline},
    {'title': 'Preparing', 'icon': Icons.restaurant},
    {'title': 'Out for Delivery', 'icon': Icons.delivery_dining},
    {'title': 'Delivered', 'icon': Icons.check_circle},
  ];

  @override
  Widget build(BuildContext context) {
    if (isCancelled) {
      return _buildCancelledState();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(_steps.length, (index) {
          final isCompleted = index <= currentStep;
          final isCurrent = index == currentStep;
          final isLast = index == _steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator (circle + connecting line)
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppTheme.primaryColor
                          : AppTheme.dividerColor,
                      border: isCurrent
                          ? Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              width: 4)
                          : null,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : _steps[index]['icon'] as IconData,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: index < currentStep
                          ? AppTheme.primaryColor
                          : AppTheme.dividerColor,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Step label
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _steps[index]['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    color: isCompleted
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCancelledState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.errorColor,
            ),
            child: const Icon(Icons.cancel, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 12),
          const Text(
            'Order Cancelled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }
}
