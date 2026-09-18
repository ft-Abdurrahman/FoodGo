// File: lib/providers/favorite_provider.dart
// Manages user's favorite restaurants (toggle, check, list)

import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class FavoriteProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<String> _favoriteRestaurantIds = [];
  bool _isLoading = false;

  List<String> get favoriteRestaurantIds =>
      List.unmodifiable(_favoriteRestaurantIds);
  bool get isLoading => _isLoading;

  /// Start listening to favorite changes for a user
  void listenToFavorites(String userId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getFavoriteRestaurants(userId).listen((favorites) {
      _favoriteRestaurantIds = favorites;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Check if a restaurant is favorited
  bool isFavorite(String restaurantId) {
    return _favoriteRestaurantIds.contains(restaurantId);
  }

  /// Toggle favorite status for a restaurant
  Future<void> toggleFavorite(String userId, String restaurantId) async {
    final isFav = isFavorite(restaurantId);
    await _firestoreService.toggleFavoriteRestaurant(
      userId,
      restaurantId,
      !isFav,
    );
    // The stream listener will update the list automatically
  }
}
