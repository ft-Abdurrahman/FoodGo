// File: lib/screens/category/category_food_list_screen.dart
// Shows all food items for a selected category

import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../models/food_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/food_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../food/food_detail_screen.dart';

class CategoryFoodListScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryFoodListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: FutureBuilder<List<FoodModel>>(
        future: firestoreService.getFoodsByCategory(category.name),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading foods...');
          }

          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Something went wrong',
              subtitle: 'Please try again later',
            );
          }

          final foods = snapshot.data ?? [];

          if (foods.isEmpty) {
            return EmptyState(
              icon: Icons.restaurant_menu,
              title: 'No foods found',
              subtitle: 'No items available in ${category.name} category',
              actionText: 'Go Back',
              onAction: () => Navigator.pop(context),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
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
            },
          );
        },
      ),
    );
  }
}
