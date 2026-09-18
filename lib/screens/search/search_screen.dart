// File: lib/screens/search/search_screen.dart
// Search screen for finding restaurants and food items

import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/restaurant_model.dart';
import '../../models/food_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/food_card.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../restaurant/restaurant_detail_screen.dart';
import '../food/food_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _firestoreService = FirestoreService();
  List<RestaurantModel> _restaurantResults = [];
  List<FoodModel> _foodResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _restaurantResults = [];
        _foodResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final restaurants =
          await _firestoreService.searchRestaurants(query.trim());
      final foods = await _firestoreService.searchFoods(query.trim());

      setState(() {
        _restaurantResults = restaurants;
        _foodResults = foods;
        _isSearching = false;
        _hasSearched = true;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _hasSearched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalResults = _restaurantResults.length + _foodResults.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Search food, restaurant...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _restaurantResults = [];
                            _foodResults = [];
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
              onChanged: (value) {
                setState(() {}); // Update clear button visibility
              },
            ),
          ),
          // Results
          Expanded(
            child: _isSearching
                ? const LoadingIndicator(message: 'Searching...')
                : _hasSearched && totalResults == 0
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'No results found',
                        subtitle:
                            'Try searching with different keywords',
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          // Restaurant results
                          if (_restaurantResults.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Restaurants (${_restaurantResults.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ..._restaurantResults.map((restaurant) {
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
                            }),
                          ],
                          // Food results
                          if (_foodResults.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Food Items (${_foodResults.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ..._foodResults.map((food) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: FoodCard(
                                  food: food,
                                  restaurantName: '',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FoodDetailScreen(
                                          food: food,
                                          restaurantName: '',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
