// File: lib/screens/admin/admin_dashboard.dart
// Admin dashboard with navigation to manage restaurants, foods, orders, users

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_restaurants_screen.dart';
import 'admin_users_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  static const String routeName = '/admin';

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Start listening to all orders for admin
    context.read<OrderProvider>().listenToAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  LoginScreen.routeName,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Text(
              'Welcome, ${auth.userModel?.name ?? 'Admin'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage your food delivery platform',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Orders',
                    orderProvider.orders.length.toString(),
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    orderProvider.activeOrders.length.toString(),
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: _firestoreService.getRestaurants(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return _buildStatCard(
                        'Restaurants',
                        count.toString(),
                        Icons.restaurant,
                        AppTheme.primaryColor,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder(
                    stream: _firestoreService.getAllUsers(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return _buildStatCard(
                        'Users',
                        count.toString(),
                        Icons.people,
                        Colors.purple,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Management sections
            const Text(
              'Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context,
              icon: Icons.receipt_long,
              title: 'Manage Orders',
              subtitle:
                  'View and update order statuses',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminOrdersScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildMenuCard(
              context,
              icon: Icons.restaurant,
              title: 'Manage Restaurants',
              subtitle: 'Add, edit, or remove restaurants',
              color: AppTheme.primaryColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminRestaurantsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildMenuCard(
              context,
              icon: Icons.people,
              title: 'View Users',
              subtitle: 'See registered user information',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUsersScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
