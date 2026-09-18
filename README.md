# FoodGo

A modern food delivery and restaurant ordering application built with **Flutter**, **Dart**, and **Firebase**.

FoodGo is a production-style mobile application demonstrating real-world Flutter development skills including Firebase authentication (Phone OTP + Email/Password), Firestore database, Cloud Functions, push notifications, state management with Provider, and a complete admin dashboard. Works entirely on Firebase's free Spark plan -- no paid subscription required.

---

## Features

### Customer App
- Phone OTP Authentication (Firebase Phone Auth)
- Email/Password Authentication with signup, login, and password reset
- Browse restaurants with images, ratings, and delivery info
- Food categories with dynamic filtering
- Search restaurants and food items
- Food detail pages with quantity selector
- Shopping cart with add/remove/quantity controls
- Address management (add, edit, delete, set default)
- Checkout with order summary
- Cash on Delivery payment
- Real-time order tracking with status updates
- Order history (active and past orders)
- Favorite restaurants
- Profile management
- Push notifications for order updates

### Admin Dashboard
- Overview statistics (orders, restaurants, users)
- Manage restaurants (add, edit, delete, toggle open/closed)
- Manage food items (add, edit, delete, availability)
- View and update all order statuses
- View registered users
- Image URLs for restaurants and foods (paste any image URL)

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter, Dart |
| Design | Material 3, Google Fonts |
| State Management | Provider |
| Backend | Firebase (free Spark plan) |
| Authentication | Firebase Auth (Phone OTP + Email/Password) |
| Database | Cloud Firestore |
| Notifications | Firebase Cloud Messaging (FCM) |
| Cloud Functions | Firebase Functions (Node.js) |
| Image Loading | cached_network_image (direct URLs) |

---

## Architecture

```
lib/
├── main.dart                    # App entry point, provider setup
├── firebase_options.dart        # Firebase configuration
│
├── models/                      # Data models
│   ├── user_model.dart
│   ├── restaurant_model.dart
│   ├── food_model.dart
│   ├── cart_model.dart
│   ├── order_model.dart
│   ├── category_model.dart
│   ├── banner_model.dart
│   └── address_model.dart
│
├── services/                    # Firebase service layer
│   ├── auth_service.dart        # Authentication operations
│   ├── firestore_service.dart   # All Firestore CRUD
│   ├── notification_service.dart # FCM setup
│   └── order_service.dart       # Order operations
│
├── providers/                   # State management (Provider)
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── cart_provider.dart
│   ├── favorite_provider.dart
│   └── order_provider.dart
│
├── screens/                     # UI screens
│   ├── splash_screen.dart
│   ├── auth/                    # Login, signup, OTP, forgot password
│   ├── home/                    # Home screen, main bottom nav
│   ├── restaurant/              # Restaurant detail
│   ├── food/                    # Food detail
│   ├── cart/                    # Shopping cart
│   ├── checkout/                # Checkout screen
│   ├── orders/                  # Order tracking, my orders
│   ├── profile/                 # Profile, edit, addresses
│   ├── favorites/               # Favorites screen
│   ├── search/                  # Search screen
│   ├── category/                # Category food list
│   └── admin/                   # Admin dashboard, orders, restaurants, users
│
├── widgets/                     # Reusable widgets
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── restaurant_card.dart
│   ├── food_card.dart
│   ├── category_item.dart
│   ├── order_status_widget.dart
│   ├── loading_indicator.dart
│   └── empty_state.dart
│
├── theme/
│   └── app_theme.dart           # Material 3 theme configuration
│
└── utils/
    ├── constants.dart           # Collection names, statuses, app constants
    ├── helpers.dart             # Formatting, validation utilities
    └── sample_data_seeder.dart  # Development data seeder
```

---

## Firebase Database Structure

```
Firestore
├── users/{userId}
│   ├── name, email, phone, profileImage, role
│   ├── addresses/{addressId}
│   └── favorites/{favoriteId}
│
├── restaurants/{restaurantId}
│   ├── name, description, image, rating, deliveryTime
│   ├── deliveryFee, minimumOrder, isOpen, category
│   └── foods/{foodId}
│       ├── name, description, price, image, category
│       └── rating, isAvailable, isVeg
│
├── categories/{categoryId}
│   └── name, image, isActive
│
├── orders/{orderId}
│   ├── orderId, userId, restaurantId, restaurantName
│   ├── items[], deliveryAddress, paymentMethod
│   ├── subtotal, deliveryFee, discount, totalAmount
│   └── status, createdAt, updatedAt
│
└── banners/{bannerId}
    └── image, title, isActive
```

Note: Images use direct URLs (e.g., from Unsplash, Imgur). No Firebase Storage required.

---

## Setup Instructions

### Prerequisites
- Flutter SDK (3.1.0+)
- Dart SDK (3.1.0+)
- Firebase account
- Android Studio / Xcode (for emulators)

### 1. Create Flutter Project
```bash
flutter create foodgo
cd foodgo
```

### 2. Copy Project Files
Copy all files from this project into your Flutter project.

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project" and follow the setup wizard
3. Name your project (e.g., "foodgo-app")

#### Register Android App
1. In Firebase Console, click the Android icon
2. Enter your package name (e.g., `com.example.foodgo`)
3. Download `google-services.json` and place it in `android/app/`

#### Register iOS App (optional)
1. Click the iOS icon in Firebase Console
2. Enter your bundle ID (e.g., `com.example.foodgo`)
3. Download `GoogleService-Info.plist` and place it in `ios/Runner/`

#### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
This generates `lib/firebase_options.dart` with your project's config values.

### 5. Enable Firebase Services

In Firebase Console:

1. **Authentication** > Sign-in method
   - Enable "Phone" (for OTP)
   - Enable "Email/Password"

2. **Firestore Database**
   - Create database
   - Start in test mode (update rules later)

3. **Cloud Messaging**
   - Already enabled by default

### 6. Deploy Security Rules
```bash
firebase deploy --only firestore:rules
```

### 7. Deploy Cloud Functions
```bash
cd firebase/functions
npm install
cd ../..
firebase deploy --only functions
```

### 8. Deploy Firestore Indexes
```bash
firebase deploy --only firestore:indexes
```

### 9. Seed Sample Data
In your app, call the seeder (e.g., from a debug button):
```dart
import 'package:foodgo/utils/sample_data_seeder.dart';

// In a debug screen or initState:
await SampleDataSeeder().seedSampleData();
```

This creates:
- 8 food categories
- 5 restaurants with 3 food items each (15 foods total)
- 3 promotional banners

### 10. Run the App
```bash
flutter run
```

---

## Firebase Configuration

### Update firebase_options.dart
After running `flutterfire configure`, the file is auto-generated. If configuring manually, replace the placeholder values in `lib/firebase_options.dart` with your Firebase project credentials from:
Firebase Console > Project Settings > Your Apps

### Admin User Setup
To create an admin user:
1. Register a user through the app (they'll be created as "customer")
2. In Firebase Console > Firestore > users > {userId}
3. Change the `role` field from `"customer"` to `"admin"`
4. The user will see the admin dashboard on next login

---

## Security Rules Summary

| Collection | Read | Write |
|-----------|------|-------|
| users/{userId} | Owner + Admin | Owner (no role change) |
| users/{userId}/addresses | Owner only | Owner only |
| users/{userId}/favorites | Owner only | Owner only |
| restaurants | Everyone | Admin only |
| restaurants/{id}/foods | Everyone | Admin only |
| categories | Everyone | Admin only |
| banners | Everyone | Admin only |
| orders | Owner + Admin | Owner (create/cancel) + Admin (all) |

Key security features:
- Users cannot escalate their own role to admin
- Customers cannot modify restaurant data or food prices
- Order status changes are admin-only (except cancellation of own placed orders)

---

## Screenshots

Add screenshots of your app here:
- Splash Screen
- Login (Phone OTP)
- Login (Email)
- Home Screen
- Restaurant Detail
- Food Detail
- Cart
- Checkout
- Order Tracking
- Profile
- Admin Dashboard

---

## Future Improvements

- [ ] Real payment integration (Razorpay / Stripe)
- [ ] Google Maps for delivery address selection
- [ ] Restaurant owner panel (separate from admin)
- [ ] Promo codes and discounts
- [ ] Order ratings and reviews
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Live order tracking with map
- [ ] Chat with restaurant/delivery partner
- [ ] Analytics dashboard for admin
- [ ] Unit and widget tests

---

## License

This project is built as a portfolio/demo application.
