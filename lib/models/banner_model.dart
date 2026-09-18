// File: lib/models/banner_model.dart
// Represents a promotional banner stored in Firestore banners collection

import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String image;
  final String? title;
  final String? restaurantId;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.image,
    this.title,
    this.restaurantId,
    this.isActive = true,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      image: data['image'] ?? '',
      title: data['title'],
      restaurantId: data['restaurantId'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'image': image,
      'title': title,
      'restaurantId': restaurantId,
      'isActive': isActive,
    };
  }
}
