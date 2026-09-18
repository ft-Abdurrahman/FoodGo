// File: lib/main.dart
// Application entry point - initializes Firebase, sets up providers, and defines the app

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_screen.dart';
import 'screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize push notification service
  await NotificationService().init();

  runApp(const FoodGoApp());
}

/// Root widget that sets up all providers and theme
class FoodGoApp extends StatelessWidget {
  const FoodGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth state - manages login/signup/OTP flows
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // User profile data from Firestore
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Shopping cart state
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // Favorite restaurants/foods
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        // Order management
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'FoodGo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            // Route to splash on first launch, then decide auth state
            home: const SplashScreen(),
            // Named routes for the entire app
            routes: {
              SplashScreen.routeName: (_) => const SplashScreen(),
              LoginScreen.routeName: (_) => const LoginScreen(),
              MainScreen.routeName: (_) => const MainScreen(),
              AdminDashboard.routeName: (_) => const AdminDashboard(),
            },
          );
        },
      ),
    );
  }
}
