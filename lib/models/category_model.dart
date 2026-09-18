// File: lib/models/category_model.dart
// Represents a food category stored in Firestore categories collection

import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String image;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.isActive = true,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'image': image,
      'isActive': isActive,
    };
  }
}
