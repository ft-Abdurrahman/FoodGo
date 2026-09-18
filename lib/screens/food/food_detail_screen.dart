// File: lib/screens/food/food_detail_screen.dart
// Food item detail page with image, description, quantity selector, add to cart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/food_model.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/helpers.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodModel food;
  final String restaurantName;

  const FoodDetailScreen({
    super.key,
    required this.food,
    required this.restaurantName,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // If item already in cart, start with that quantity
    final cart = context.read<CartProvider>();
    final existingQty = cart.getQuantity(widget.food.id);
    if (existingQty > 0) {
      _quantity = existingQty;
    }
  }

  void _addToCart() {
    final cart = context.read<CartProvider>();

    // Clear current cart quantity for this item and set to desired quantity
    final currentQty = cart.getQuantity(widget.food.id);
    if (currentQty == 0) {
      // Add new items
      for (int i = 0; i < _quantity; i++) {
        cart.addItem(widget.food, widget.restaurantName);
      }
    } else {
      // Adjust quantity
      final diff = _quantity - currentQty;
      if (diff > 0) {
        for (int i = 0; i < diff; i++) {
          cart.incrementQuantity(widget.food.id);
        }
      } else if (diff < 0) {
        for (int i = 0; i < -diff; i++) {
          cart.decrementQuantity(widget.food.id);
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.food.name} added to cart',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final totalPrice = food.price * _quantity;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Large food image ──
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: food.image,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.dividerColor,
                      child: const Center(
                        child: Icon(Icons.fastfood, size: 60),
                      ),
                    ),
                  ),
                  // Gradient at bottom
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Food details ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant name
                  Text(
                    widget.restaurantName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Food name
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rating and veg indicator
                  Row(
                    children: [
                      // Veg/Non-veg badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: food.isVeg
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: food.isVeg
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              food.isVeg ? 'Veg' : 'Non-Veg',
                              style: TextStyle(
                                fontSize: 11,
                                color: food.isVeg
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Rating
                      if (food.rating > 0) ...[
                        const Icon(Icons.star,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          food.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          food.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    food.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Price
                  Text(
                    AppHelpers.formatPrice(food.price),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quantity selector
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Decrease button
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onTap: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      // Quantity display
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _quantity.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Increase button
                      _buildQuantityButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // ── Bottom bar: total price + add to cart ──
      bottomNavigationBar: food.isAvailable
          ? Container(
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
                child: Row(
                  children: [
                    // Total price
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          AppHelpers.formatPrice(totalPrice),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Add to cart button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addToCart,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Add to Cart • ${AppHelpers.formatPrice(totalPrice)}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.surfaceColor,
              child: SafeArea(
                child: const Center(
                  child: Text(
                    'This item is currently unavailable',
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppTheme.primaryColor
              : AppTheme.dividerColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: onTap != null ? Colors.white : AppTheme.textHint,
          size: 20,
        ),
      ),
    );
  }
}
