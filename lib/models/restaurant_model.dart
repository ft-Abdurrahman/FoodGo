// File: lib/models/restaurant_model.dart
// Represents a restaurant stored in Firestore restaurants collection

import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final double rating;
  final String deliveryTime; // e.g., "25-30 min"
  final double deliveryFee;
  final double minimumOrder;
  final bool isOpen;
  final String category;
  final String? location;
  final DateTime createdAt;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.minimumOrder,
    this.isOpen = true,
    required this.category,
    this.location,
    required this.createdAt,
  });

  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      deliveryTime: data['deliveryTime'] ?? '',
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      minimumOrder: (data['minimumOrder'] ?? 0).toDouble(),
      isOpen: data['isOpen'] ?? true,
      category: data['category'] ?? '',
      location: data['location'],
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'minimumOrder': minimumOrder,
      'isOpen': isOpen,
      'category': category,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  RestaurantModel copyWith({
    String? name,
    String? description,
    String? image,
    double? rating,
    String? deliveryTime,
    double? deliveryFee,
    double? minimumOrder,
    bool? isOpen,
    String? category,
    String? location,
  }) {
    return RestaurantModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      isOpen: isOpen ?? this.isOpen,
      category: category ?? this.category,
      location: location ?? this.location,
      createdAt: createdAt,
    );
  }
}
