// File: lib/widgets/food_card.dart
// Card widget for displaying a food item in lists

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/food_model.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

class FoodCard extends StatelessWidget {
  final FoodModel food;
  final String restaurantName;
  final VoidCallback? onTap;

  const FoodCard({
    super.key,
    required this.food,
    required this.restaurantName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final quantity = cartProvider.getQuantity(food.id);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Food image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: food.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: AppTheme.dividerColor,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: AppTheme.dividerColor,
                    child: const Icon(Icons.fastfood, size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Food details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Veg/Non-veg indicator
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: food.isVeg
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: food.isVeg
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          food.isVeg ? 'Veg' : 'Non-Veg',
                          style: TextStyle(
                            fontSize: 11,
                            color: food.isVeg
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      restaurantName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          AppHelpers.formatPrice(food.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (food.rating > 0) ...[
                          const Icon(Icons.star,
                              color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            food.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Add to cart button / quantity controls
              _buildCartButton(context, cartProvider, quantity),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartButton(
      BuildContext context, CartProvider cart, int quantity) {
    if (quantity == 0) {
      return ElevatedButton(
        onPressed: () {
          cart.addItem(food, restaurantName);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${food.name} added to cart'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(0, 36),
        ),
        child: const Text('ADD', style: TextStyle(fontSize: 13)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => cart.decrementQuantity(food.id),
            icon: const Icon(Icons.remove, size: 16, color: Colors.white),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: () => cart.incrementQuantity(food.id),
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
