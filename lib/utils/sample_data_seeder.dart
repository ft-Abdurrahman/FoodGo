// File: lib/utils/sample_data_seeder.dart
// Script to populate Firestore with sample development data
//
// Usage: Run this from your Flutter project after Firebase is configured.
// You can call seedSampleData() from a debug button or a temporary screen.
//
// IMPORTANT: Only use this for development. Remove or disable in production.

import 'package:cloud_firestore/cloud_firestore.dart';

class SampleDataSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Seed all sample data into Firestore
  /// Call this once during development to populate the database
  Future<void> seedSampleData() async {
    await _seedCategories();
    await _seedRestaurants();
    await _seedBanners();
  }

  // ──────────────────────────────────────────────
  // Categories
  // ──────────────────────────────────────────────

  Future<void> _seedCategories() async {
    final categories = [
      {'name': 'Pizza', 'image': '', 'isActive': true},
      {'name': 'Burger', 'image': '', 'isActive': true},
      {'name': 'Biryani', 'image': '', 'isActive': true},
      {'name': 'Chicken', 'image': '', 'isActive': true},
      {'name': 'Chinese', 'image': '', 'isActive': true},
      {'name': 'Desserts', 'image': '', 'isActive': true},
      {'name': 'Drinks', 'image': '', 'isActive': true},
      {'name': 'Noodles', 'image': '', 'isActive': true},
    ];

    final batch = _db.batch();
    for (final cat in categories) {
      final docRef = _db.collection('categories').doc();
      batch.set(docRef, cat);
    }
    await batch.commit();
  }

  // ──────────────────────────────────────────────
  // Restaurants with Foods
  // ──────────────────────────────────────────────

  Future<void> _seedRestaurants() async {
    // Restaurant 1: Pizza Palace
    final pizzaRef = await _db.collection('restaurants').add({
      'name': 'Pizza Palace',
      'description': 'Authentic Italian pizzas baked in wood-fired ovens with fresh ingredients.',
      'image': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500',
      'rating': 4.5,
      'deliveryTime': '25-35 min',
      'deliveryFee': 40.0,
      'minimumOrder': 149.0,
      'isOpen': true,
      'category': 'Pizza',
      'location': 'MG Road, Bangalore',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _addFoods(pizzaRef.id, [
      {
        'name': 'Margherita Pizza',
        'description': 'Classic pizza with fresh tomato sauce, mozzarella cheese, and basil.',
        'price': 199.0,
        'image': 'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?w=400',
        'category': 'Pizza',
        'rating': 4.7,
        'isAvailable': true,
        'isVeg': true,
      },
      {
        'name': 'Pepperoni Pizza',
        'description': 'Loaded with spicy pepperoni slices and melted mozzarella.',
        'price': 299.0,
        'image': 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400',
        'category': 'Pizza',
        'rating': 4.6,
        'isAvailable': true,
        'isVeg': false,
      },
      {
        'name': 'Farmhouse Pizza',
        'description': 'Fresh vegetables, onions, capsicum, and tomatoes on a cheesy base.',
        'price': 249.0,
        'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
        'category': 'Pizza',
        'rating': 4.3,
        'isAvailable': true,
        'isVeg': true,
      },
    ]);

    // Restaurant 2: Burger Barn
    final burgerRef = await _db.collection('restaurants').add({
      'name': 'Burger Barn',
      'description': 'Juicy handcrafted burgers made with premium beef and fresh buns.',
      'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
      'rating': 4.3,
      'deliveryTime': '20-30 min',
      'deliveryFee': 30.0,
      'minimumOrder': 99.0,
      'isOpen': true,
      'category': 'Burger',
      'location': 'Koramangala, Bangalore',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _addFoods(burgerRef.id, [
      {
        'name': 'Classic Cheese Burger',
        'description': 'Juicy beef patty with cheddar cheese, lettuce, and special sauce.',
        'price': 149.0,
        'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
        'category': 'Burger',
        'rating': 4.5,
        'isAvailable': true,
        'isVeg': false,
      },
      {
        'name': 'Veggie Burger',
        'description': 'Crispy veggie patty with fresh lettuce, tomato, and mayo.',
        'price': 119.0,
        'image': 'https://images.unsplash.com/photo-1520072959219-c595dc870360?w=400',
        'category': 'Burger',
        'rating': 4.2,
        'isAvailable': true,
        'isVeg': true,
      },
      {
        'name': 'Double Smash Burger',
        'description': 'Two smashed patties with American cheese, pickles, and burger sauce.',
        'price': 229.0,
        'image': 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=400',
        'category': 'Burger',
        'rating': 4.8,
        'isAvailable': true,
        'isVeg': false,
      },
    ]);

    // Restaurant 3: Biryani House
    final biryaniRef = await _db.collection('restaurants').add({
      'name': 'Biryani House',
      'description': 'Aromatic dum biryanis cooked in traditional style with fragrant basmati rice.',
      'image': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500',
      'rating': 4.6,
      'deliveryTime': '30-45 min',
      'deliveryFee': 50.0,
      'minimumOrder': 199.0,
      'isOpen': true,
      'category': 'Biryani',
      'location': 'Indiranagar, Bangalore',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _addFoods(biryaniRef.id, [
      {
        'name': 'Chicken Dum Biryani',
        'description': 'Slow-cooked chicken biryani with aromatic spices and saffron rice.',
        'price': 249.0,
        'image': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400',
        'category': 'Biryani',
        'rating': 4.8,
        'isAvailable': true,
        'isVeg': false,
      },
      {
        'name': 'Mutton Biryani',
        'description': 'Tender mutton pieces layered with fragrant rice and special masala.',
        'price': 329.0,
        'image': 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400',
        'category': 'Biryani',
        'rating': 4.7,
        'isAvailable': true,
        'isVeg': false,
      },
      {
        'name': 'Veg Biryani',
        'description': 'Mixed vegetables cooked with basmati rice and biryani spices.',
        'price': 179.0,
        'image': 'https://images.unsplash.com/photo-1630409351217-bc4fa6420075?w=400',
        'category': 'Biryani',
        'rating': 4.3,
        'isAvailable': true,
        'isVeg': true,
      },
    ]);

    // Restaurant 4: Dragon Wok
    final chineseRef = await _db.collection('restaurants').add({
      'name': 'Dragon Wok',
      'description': 'Authentic Chinese cuisine with a modern twist. From sizzling noodles to dim sums.',
      'image': 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=500',
      'rating': 4.2,
      'deliveryTime': '25-35 min',
      'deliveryFee': 35.0,
      'minimumOrder': 149.0,
      'isOpen': true,
      'category': 'Chinese',
      'location': 'HSR Layout, Bangalore',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _addFoods(chineseRef.id, [
      {
        'name': 'Hakka Noodles',
        'description': 'Stir-fried noodles with fresh vegetables and soy sauce.',
        'price': 159.0,
        'image': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
        'category': 'Noodles',
        'rating': 4.3,
        'isAvailable': true,
        'isVeg': true,
      },
      {
        'name': 'Chicken Manchurian',
        'description': 'Crispy chicken tossed in spicy Manchurian sauce with spring onions.',
        'price': 219.0,
        'image': 'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=400',
        'category': 'Chicken',
        'rating': 4.5,
        'isAvailable': true,
        'isVeg': false,
      },
      {
        'name': 'Fried Rice',
        'description': 'Wok-tossed rice with vegetables, egg, and aromatic seasonings.',
        'price': 139.0,
        'image': 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400',
        'category': 'Chinese',
        'rating': 4.1,
        'isAvailable': true,
        'isVeg': false,
      },
    ]);

    // Restaurant 5: Sweet Tooth
    final dessertRef = await _db.collection('restaurants').add({
      'name': 'Sweet Tooth',
      'description': 'Indulgent desserts and beverages to satisfy your sweet cravings.',
      'image': 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=500',
      'rating': 4.4,
      'deliveryTime': '15-25 min',
      'deliveryFee': 25.0,
      'minimumOrder': 79.0,
      'isOpen': true,
      'category': 'Desserts',
      'location': 'Whitefield, Bangalore',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _addFoods(dessertRef.id, [
      {
        'name': 'Chocolate Brownie',
        'description': 'Warm, gooey chocolate brownie served with vanilla ice cream.',
        'price': 129.0,
        'image': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400',
        'category': 'Desserts',
        'rating': 4.6,
        'isAvailable': true,
        'isVeg': true,
      },
      {
        'name': 'Mango Shake',
        'description': 'Fresh Alphonso mango blended with cream and ice.',
        'price': 99.0,
        'image': 'https://images.unsplash.com/photo-1546173159-315724a31696?w=400',
        'category': 'Drinks',
        'rating': 4.4,
        'isAvailable': true,
        'isVeg': true,
      },
      {
        'name': 'Gulab Jamun',
        'description': 'Soft milk dumplings soaked in warm cardamom-flavored sugar syrup.',
        'price': 79.0,
        'image': 'https://images.unsplash.com/photo-1666190050918-68c0a8d0f3e7?w=400',
        'category': 'Desserts',
        'rating': 4.5,
        'isAvailable': true,
        'isVeg': true,
      },
    ]);
  }

  // ──────────────────────────────────────────────
  // Helper: Add food items to a restaurant
  // ──────────────────────────────────────────────

  Future<void> _addFoods(
      String restaurantId, List<Map<String, dynamic>> foods) async {
    final batch = _db.batch();
    for (final food in foods) {
      final docRef = _db
          .collection('restaurants')
          .doc(restaurantId)
          .collection('foods')
          .doc();
      food['restaurantId'] = restaurantId;
      food['createdAt'] = FieldValue.serverTimestamp();
      batch.set(docRef, food);
    }
    await batch.commit();
  }

  // ──────────────────────────────────────────────
  // Banners
  // ──────────────────────────────────────────────

  Future<void> _seedBanners() async {
    final banners = [
      {
        'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
        'title': '50% OFF on First Order',
        'isActive': true,
      },
      {
        'image': 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=800',
        'title': 'Free Delivery Above ₹499',
        'isActive': true,
      },
      {
        'image': 'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=800',
        'title': 'New Restaurants Added!',
        'isActive': true,
      },
    ];

    final batch = _db.batch();
    for (final banner in banners) {
      final docRef = _db.collection('banners').doc();
      batch.set(docRef, banner);
    }
    await batch.commit();
  }
}
