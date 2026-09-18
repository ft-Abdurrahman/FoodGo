// File: lib/models/food_model.dart
// Represents a food item stored as subcollection under a restaurant

import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category; // e.g., "Pizza", "Burger"
  final double rating;
  final bool isAvailable;
  final bool isVeg;
  final DateTime createdAt;

  FoodModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.rating = 0.0,
    this.isAvailable = true,
    this.isVeg = false,
    required this.createdAt,
  });

  factory FoodModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      isAvailable: data['isAvailable'] ?? true,
      isVeg: data['isVeg'] ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'rating': rating,
      'isAvailable': isAvailable,
      'isVeg': isVeg,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  FoodModel copyWith({
    String? name,
    String? description,
    double? price,
    String? image,
    String? category,
    double? rating,
    bool? isAvailable,
    bool? isVeg,
  }) {
    return FoodModel(
      id: id,
      restaurantId: restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      isAvailable: isAvailable ?? this.isAvailable,
      isVeg: isVeg ?? this.isVeg,
      createdAt: createdAt,
    );
  }
}
