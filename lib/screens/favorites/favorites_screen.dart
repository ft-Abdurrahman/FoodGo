// File: lib/screens/favorites/favorites_screen.dart
// Shows user's favorite restaurants

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant_model.dart';
import '../../providers/favorite_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../restaurant/restaurant_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoriteProvider>();
    final firestoreService = FirestoreService();
    final favoriteIds = favProvider.favoriteRestaurantIds;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favProvider.isLoading
          ? const LoadingIndicator()
          : favoriteIds.isEmpty
              ? const EmptyState(
                  icon: Icons.favorite_outline,
                  title: 'No favorites yet',
                  subtitle:
                      'Tap the heart icon on restaurants to save them here',
                )
              : FutureBuilder<List<RestaurantModel>>(
                  future: _getFavoriteRestaurants(
                      firestoreService, favoriteIds),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const LoadingIndicator();
                    }

                    final restaurants = snapshot.data!;

                    if (restaurants.isEmpty) {
                      return const EmptyState(
                        icon: Icons.favorite_outline,
                        title: 'No favorites found',
                        subtitle: 'Some restaurants may have been removed',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurants[index];
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 4),
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
                        );
                      },
                    );
                  },
                ),
    );
  }

  /// Fetch restaurant models for the favorite IDs
  Future<List<RestaurantModel>> _getFavoriteRestaurants(
    FirestoreService service,
    List<String> ids,
  ) async {
    final List<RestaurantModel> restaurants = [];
    for (final id in ids) {
      final restaurant = await service.getRestaurant(id);
      if (restaurant != null) {
        restaurants.add(restaurant);
      }
    }
    return restaurants;
  }
}
