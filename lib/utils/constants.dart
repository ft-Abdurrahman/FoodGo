// File: lib/utils/constants.dart
// Application-wide constants for Firestore collections, routes, and shared values

class AppConstants {
  AppConstants._();

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String restaurantsCollection = 'restaurants';
  static const String categoriesCollection = 'categories';
  static const String ordersCollection = 'orders';
  static const String bannersCollection = 'banners';

  // Subcollection names
  static const String foodsSubcollection = 'foods';
  static const String addressesSubcollection = 'addresses';
  static const String favoritesSubcollection = 'favorites';

  // User roles
  static const String roleCustomer = 'customer';
  static const String roleAdmin = 'admin';

  // Order statuses
  static const String statusPlaced = 'placed';
  static const String statusConfirmed = 'confirmed';
  static const String statusPreparing = 'preparing';
  static const String statusOutForDelivery = 'outForDelivery';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';

  // Payment methods
  static const String paymentCOD = 'Cash on Delivery';
  static const String paymentUPI = 'UPI';
  static const String paymentCard = 'Card';

  // Delivery fee
  static const double deliveryFee = 40.0;
  static const double freeDeliveryAbove = 499.0;

  // App info
  static const String appName = 'FoodGo';
  static const String appVersion = '1.0.0';
}
