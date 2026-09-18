// File: lib/screens/home/home_screen.dart
// Main home screen with greeting, categories, banners, restaurants, and popular foods

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../models/restaurant_model.dart';
import '../../models/food_model.dart';
import '../../models/category_model.dart';
import '../../models/banner_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/category_item.dart';
import '../../utils/helpers.dart';
import '../restaurant/restaurant_detail_screen.dart';
import '../food/food_detail_screen.dart';
import '../category/category_food_list_screen.dart';
import '../cart/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestoreService = FirestoreService();
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final cart = context.watch<CartProvider>();
    final userName = auth.userModel?.name ?? 'Foodie';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header: Greeting + Profile ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    // Profile image
                    GestureDetector(
                      onTap: () {},
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        backgroundImage: auth.userModel?.profileImage != null
                            ? CachedNetworkImageProvider(
                                auth.userModel!.profileImage!)
                            : null,
                        child: auth.userModel?.profileImage == null
                            ? const Icon(Icons.person,
                                color: AppTheme.primaryColor)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $userName 👋',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 16, color: AppTheme.primaryColor),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  userProvider.selectedAddress?.label ??
                                      'Set delivery address',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down,
                                  size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Cart icon with badge
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_outlined),
                        ),
                        if (cart.totalQuantity > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                cart.totalQuantity.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ── Search Bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to search - handled by bottom nav
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: AppTheme.textHint),
                        SizedBox(width: 12),
                        Text(
                          'Search food or restaurant...',
                          style: TextStyle(color: AppTheme.textHint),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ── Categories ──
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 95,
                    child: StreamBuilder<List<CategoryModel>>(
                      stream: _firestoreService.getCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        final categories = snapshot.data ?? [];
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: CategoryItem(
                                category: category,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CategoryFoodListScreen(
                                              category: category),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // ── Promotional Banners ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: StreamBuilder<List<BannerModel>>(
                  stream: _firestoreService.getBanners(),
                  builder: (context, snapshot) {
                    final banners = snapshot.data ?? [];
                    if (banners.isEmpty) return const SizedBox.shrink();

                    return Column(
                      children: [
                        SizedBox(
                          height: 150,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: banners.length,
                            itemBuilder: (context, index) {
                              final banner = banners[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: banner.image.isNotEmpty
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              banner.image),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: AppTheme.primaryColor
                                      .withOpacity(0.1),
                                ),
                                child: banner.image.isEmpty
                                    ? Center(
                                        child: Text(
                                          banner.title ?? 'Special Offer',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: banners.length,
                          effect: WormEffect(
                            dotWidth: 8,
                            dotHeight: 8,
                            activeDotColor: AppTheme.primaryColor,
                            dotColor: AppTheme.dividerColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // ── Popular Restaurants ──
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Popular Restaurants',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 250,
                    child: StreamBuilder<List<RestaurantModel>>(
                      stream: _firestoreService.getRestaurants(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        final restaurants = snapshot.data ?? [];
                        if (restaurants.isEmpty) {
                          return const Center(
                            child: Text('No restaurants available'),
                          );
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = restaurants[index];
                            return SizedBox(
                              width: 260,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: RestaurantCard(
                                  restaurant: restaurant,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            RestaurantDetailScreen(
                                                restaurant: restaurant),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // ── Popular Foods ──
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Popular Foods',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Load popular foods from all restaurants
                  StreamBuilder<List<RestaurantModel>>(
                    stream: _firestoreService.getRestaurants(),
                    builder: (context, restaurantSnapshot) {
                      final restaurants = restaurantSnapshot.data ?? [];
                      if (restaurants.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      // Get foods from first few restaurants for display
                      return FutureBuilder<List<FoodModel>>(
                        future: _getPopularFoods(restaurants),
                        builder: (context, foodSnapshot) {
                          if (!foodSnapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }
                          final foods = foodSnapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            itemCount: foods.length,
                            itemBuilder: (context, index) {
                              final food = foods[index];
                              final restaurant = restaurants.firstWhere(
                                (r) => r.id == food.restaurantId,
                                orElse: () => restaurants.first,
                              );
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: _buildFoodItem(
                                    context, food, restaurant.name),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fetch popular foods from restaurants
  Future<List<FoodModel>> _getPopularFoods(
      List<RestaurantModel> restaurants) async {
    final List<FoodModel> allFoods = [];
    for (final restaurant in restaurants.take(5)) {
      final foods = await _firestoreService
          .getFoods(restaurant.id)
          .first
          .then((foods) => foods.where((f) => f.isAvailable).toList());
      allFoods.addAll(foods);
    }
    // Sort by rating and take top items
    allFoods.sort((a, b) => b.rating.compareTo(a.rating));
    return allFoods.take(10).toList();
  }

  /// Build a compact food item row for the popular foods section
  Widget _buildFoodItem(
      BuildContext context, FoodModel food, String restaurantName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodDetailScreen(
              food: food,
              restaurantName: restaurantName,
            ),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: food.image,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          AppHelpers.formatPrice(food.price),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (food.rating > 0) ...[
                          const Icon(Icons.star,
                              color: Colors.amber, size: 14),
                          Text(
                            ' ${food.rating.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Add button
              Consumer<CartProvider>(
                builder: (context, cart, _) {
                  final qty = cart.getQuantity(food.id);
                  if (qty == 0) {
                    return ElevatedButton(
                      onPressed: () {
                        cart.addItem(food, restaurantName);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        minimumSize: const Size(0, 34),
                      ),
                      child: const Text('ADD',
                          style: TextStyle(fontSize: 12)),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$qty',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
