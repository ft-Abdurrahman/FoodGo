// File: lib/services/firestore_service.dart
// Central service for all Cloud Firestore read/write operations

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/restaurant_model.dart';
import '../models/food_model.dart';
import '../models/category_model.dart';
import '../models/banner_model.dart';
import '../models/address_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────────────────────────
  // Users
  // ──────────────────────────────────────────────

  /// Create or update user document after registration
  Future<void> createUser(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toFirestore());
  }

  /// Get user document by uid
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  /// Update user profile fields
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp;
    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  /// Get all users (admin only)
  Stream<List<UserModel>> getAllUsers() {
    return _db
        .collection(AppConstants.usersCollection)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  // ──────────────────────────────────────────────
  // Restaurants
  // ──────────────────────────────────────────────

  /// Stream all active restaurants
  Stream<List<RestaurantModel>> getRestaurants() {
    return _db
        .collection(AppConstants.restaurantsCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RestaurantModel.fromFirestore(doc))
            .toList());
  }

  /// Get single restaurant by ID
  Future<RestaurantModel?> getRestaurant(String id) async {
    final doc = await _db
        .collection(AppConstants.restaurantsCollection)
        .doc(id)
        .get();
    if (doc.exists) {
      return RestaurantModel.fromFirestore(doc);
    }
    return null;
  }

  /// Create a new restaurant (admin)
  Future<DocumentReference> addRestaurant(RestaurantModel restaurant) async {
    return await _db
        .collection(AppConstants.restaurantsCollection)
        .add(restaurant.toFirestore());
  }

  /// Update restaurant (admin)
  Future<void> updateRestaurant(
      String id, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.restaurantsCollection)
        .doc(id)
        .update(data);
  }

  /// Delete restaurant (admin)
  Future<void> deleteRestaurant(String id) async {
    await _db
        .collection(AppConstants.restaurantsCollection)
        .doc(id)
        .delete();
  }

  /// Search restaurants by name
  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    final snapshot = await _db
        .collection(AppConstants.restaurantsCollection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs
        .map((doc) => RestaurantModel.fromFirestore(doc))
        .toList();
  }

  // ──────────────────────────────────────────────
  // Food Items
  // ──────────────────────────────────────────────

  /// Get all food items for a restaurant
  Stream<List<FoodModel>> getFoods(String restaurantId) {
    return _db
        .collection(AppConstants.restaurantsCollection)
        .doc(restaurantId)
        .collection(AppConstants.foodsSubcollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FoodModel.fromFirestore(doc)).toList());
  }

  /// Get food items by category across all restaurants
  Future<List<FoodModel>> getFoodsByCategory(String category) async {
    // Since foods are subcollections, we need to use collectionGroup query
    final snapshot = await _db
        .collectionGroup(AppConstants.foodsSubcollection)
        .where('category', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => FoodModel.fromFirestore(doc))
        .toList();
  }

  /// Search food items by name
  Future<List<FoodModel>> searchFoods(String query) async {
    final snapshot = await _db
        .collectionGroup(AppConstants.foodsSubcollection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .where('isAvailable', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => FoodModel.fromFirestore(doc))
        .toList();
  }

  /// Add food item to restaurant (admin)
  Future<DocumentReference> addFood(String restaurantId, FoodModel food) async {
    return await _db
        .collection(AppConstants.restaurantsCollection)
        .doc(restaurantId)
        .collection(AppConstants.foodsSubcollection)
        .add(food.toFirestore());
  }

  /// Update food item (admin)
  Future<void> updateFood(
      String restaurantId, String foodId, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.restaurantsCollection)
        .doc(restaurantId)
        .collection(AppConstants.foodsSubcollection)
        .doc(foodId)
        .update(data);
  }

  /// Delete food item (admin)
  Future<void> deleteFood(String restaurantId, String foodId) async {
    await _db
        .collection(AppConstants.restaurantsCollection)
        .doc(restaurantId)
        .collection(AppConstants.foodsSubcollection)
        .doc(foodId)
        .delete();
  }

  // ──────────────────────────────────────────────
  // Categories
  // ──────────────────────────────────────────────

  /// Stream all active categories
  Stream<List<CategoryModel>> getCategories() {
    return _db
        .collection(AppConstants.categoriesCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .toList());
  }

  // ──────────────────────────────────────────────
  // Banners
  // ──────────────────────────────────────────────

  /// Stream active banners
  Stream<List<BannerModel>> getBanners() {
    return _db
        .collection(AppConstants.bannersCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BannerModel.fromFirestore(doc)).toList());
  }

  // ──────────────────────────────────────────────
  // Addresses
  // ──────────────────────────────────────────────

  /// Get all addresses for a user
  Stream<List<AddressModel>> getAddresses(String userId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.addressesSubcollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AddressModel.fromFirestore(doc))
            .toList());
  }

  /// Add new address
  Future<void> addAddress(String userId, AddressModel address) async {
    // If this is set as default, unset other defaults first
    if (address.isDefault) {
      await _unsetDefaultAddress(userId);
    }
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.addressesSubcollection)
        .add(address.toFirestore());
  }

  /// Update address
  Future<void> updateAddress(
      String userId, String addressId, AddressModel address) async {
    if (address.isDefault) {
      await _unsetDefaultAddress(userId);
    }
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.addressesSubcollection)
        .doc(addressId)
        .update(address.toFirestore());
  }

  /// Delete address
  Future<void> deleteAddress(String userId, String addressId) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.addressesSubcollection)
        .doc(addressId)
        .delete();
  }

  /// Set an address as default (unsets all others)
  Future<void> setDefaultAddress(String userId, String addressId) async {
    await _unsetDefaultAddress(userId);
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.addressesSubcollection)
        .doc(addressId)
        .update({'isDefault': true});
  }

  /// Unset all default flags for a user's addresses
  Future<void> _unsetDefaultAddress(String userId) async {
    final batch = _db.batch();
    final snapshot = await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.addressesSubcollection)
        .where('isDefault', isEqualTo: true)
        .get();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }

  // ──────────────────────────────────────────────
  // Favorites
  // ──────────────────────────────────────────────

  /// Get user's favorite restaurant IDs
  Stream<List<String>> getFavoriteRestaurants(String userId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.favoritesSubcollection)
        .where('type', isEqualTo: 'restaurant')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc['targetId'] as String).toList());
  }

  /// Toggle favorite for a restaurant
  Future<void> toggleFavoriteRestaurant(
      String userId, String restaurantId, bool isFavorite) async {
    final favRef = _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.favoritesSubcollection)
        .doc('restaurant_$restaurantId');

    if (isFavorite) {
      await favRef.set({
        'type': 'restaurant',
        'targetId': restaurantId,
        'createdAt': FieldValue.serverTimestamp,
      });
    } else {
      await favRef.delete();
    }
  }

  /// Check if a restaurant is favorited
  Future<bool> isFavoriteRestaurant(String userId, String restaurantId) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.favoritesSubcollection)
        .doc('restaurant_$restaurantId')
        .get();
    return doc.exists;
  }
}
