// File: lib/screens/cart/cart_screen.dart
// Shopping cart screen with item list, quantity controls, and price summary

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../../utils/helpers.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () async {
                final confirmed = await AppHelpers.showConfirmDialog(
                  context,
                  title: 'Clear Cart',
                  message: 'Remove all items from cart?',
                  confirmText: 'Clear',
                  isDestructive: true,
                );
                if (confirmed && context.mounted) {
                  cart.clearCart();
                }
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: cart.isEmpty
          ? const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add items from restaurants to get started',
              actionText: 'Browse Restaurants',
            )
          : Column(
              children: [
                // Cart items list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.itemCount,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _buildCartItem(context, cart, item, index);
                    },
                  ),
                ),
                // Price summary + checkout button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Price breakdown
                        _buildPriceRow(
                            'Subtotal', AppHelpers.formatPrice(cart.subtotal)),
                        _buildPriceRow(
                          'Delivery Fee',
                          cart.deliveryFee == 0
                              ? 'FREE'
                              : AppHelpers.formatPrice(cart.deliveryFee),
                          isFree: cart.deliveryFee == 0,
                        ),
                        const Divider(height: 20),
                        _buildPriceRow(
                          'Total',
                          AppHelpers.formatPrice(cart.total),
                          isTotal: true,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Proceed to Checkout',
                          icon: Icons.arrow_forward,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CheckoutScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartProvider cart,
      dynamic item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Food image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: item.image,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: AppTheme.dividerColor,
                  child: const Icon(Icons.fastfood),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.restaurantName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppHelpers.formatPrice(item.price)} × ${item.quantity}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity controls + remove
            Column(
              children: [
                // Remove button
                GestureDetector(
                  onTap: () => cart.removeItem(item.foodId),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                // Quantity controls
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () =>
                            cart.decrementQuantity(item.foodId),
                        icon: const Icon(Icons.remove,
                            size: 14, color: Colors.white),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          item.quantity.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            cart.incrementQuantity(item.foodId),
                        icon: const Icon(Icons.add,
                            size: 14, color: Colors.white),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isTotal = false, bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.w600,
              color: isFree
                  ? AppTheme.successColor
                  : isTotal
                      ? AppTheme.primaryColor
                      : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
