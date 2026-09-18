// File: lib/screens/restaurant/restaurant_detail_screen.dart
// Restaurant details page showing info, food categories, and food items

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant_model.dart';
import '../../models/food_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/food_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../food/food_detail_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final _firestoreService = FirestoreService();
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero image with overlay ──
          SliverAppBar(
            expandedHeight: 220,
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
            actions: [
              // Favorite button
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return Consumer<FavoriteProvider>(
                    builder: (context, fav, _) {
                      final isFav = fav.isFavorite(restaurant.id);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : null,
                        ),
                        onPressed: () {
                          if (auth.firebaseUser != null) {
                            fav.toggleFavorite(
                                auth.firebaseUser!.uid, restaurant.id);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: restaurant.image,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.dividerColor,
                      child: const Center(
                        child: Icon(Icons.restaurant, size: 60),
                      ),
                    ),
                  ),
                  // Gradient overlay at bottom
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Restaurant info ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Info chips
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildInfoChip(
                        Icons.star,
                        Colors.amber,
                        '${restaurant.rating.toStringAsFixed(1)} Rating',
                      ),
                      _buildInfoChip(
                        Icons.access_time,
                        AppTheme.textSecondary,
                        restaurant.deliveryTime,
                      ),
                      _buildInfoChip(
                        Icons.delivery_dining,
                        AppTheme.primaryColor,
                        '₹${restaurant.deliveryFee.toStringAsFixed(0)} delivery',
                      ),
                      _buildInfoChip(
                        Icons.shopping_bag,
                        AppTheme.textSecondary,
                        'Min ₹${restaurant.minimumOrder.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                  // Open/Closed status
                  if (!restaurant.isOpen)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppTheme.errorColor, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'This restaurant is currently closed',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          // ── Food items ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: const Text(
                'Menu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          // Food list from Firestore
          StreamBuilder<List<FoodModel>>(
            stream: _firestoreService.getFoods(restaurant.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: LoadingIndicator(),
                  ),
                );
              }

              var foods = snapshot.data ?? [];

              // Filter by category if selected
              if (_selectedCategory != null) {
                foods = foods
                    .where((f) => f.category == _selectedCategory)
                    .toList();
              }

              if (foods.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: EmptyState(
                      icon: Icons.restaurant_menu,
                      title: 'No items available',
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final food = foods[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: FoodCard(
                        food: food,
                        restaurantName: restaurant.name,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FoodDetailScreen(
                                food: food,
                                restaurantName: restaurant.name,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: foods.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
