// File: lib/screens/admin/admin_restaurants_screen.dart
// Admin screen to manage restaurants: add, edit, delete, toggle open/closed
// Images use direct URLs (no Firebase Storage required)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/restaurant_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/helpers.dart';

class AdminRestaurantsScreen extends StatelessWidget {
  const AdminRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Restaurants')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const _AddEditRestaurantScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Restaurant'),
      ),
      body: StreamBuilder<List<RestaurantModel>>(
        stream: firestoreService.getRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          final restaurants = snapshot.data ?? [];
          if (restaurants.isEmpty) {
            return const EmptyState(
              icon: Icons.restaurant,
              title: 'No restaurants',
              subtitle: 'Add your first restaurant',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return _buildRestaurantItem(
                  context, restaurant, firestoreService);
            },
          );
        },
      ),
    );
  }

  Widget _buildRestaurantItem(BuildContext context,
      RestaurantModel restaurant, FirestoreService service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: restaurant.image.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: restaurant.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 50,
                    height: 50,
                    color: AppTheme.dividerColor,
                    child: const Icon(Icons.restaurant),
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: AppTheme.dividerColor,
                  child: const Icon(Icons.restaurant),
                ),
        ),
        title: Text(restaurant.name),
        subtitle: Text(
          '${restaurant.category} • ${restaurant.rating.toStringAsFixed(1)} ★ • ${restaurant.isOpen ? "Open" : "Closed"}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'toggle':
                await service.updateRestaurant(
                  restaurant.id,
                  {'isOpen': !restaurant.isOpen},
                );
                break;
              case 'edit':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _AddEditRestaurantScreen(
                        restaurant: restaurant),
                  ),
                );
                break;
              case 'delete':
                final confirmed = await AppHelpers.showConfirmDialog(
                  context,
                  title: 'Delete Restaurant',
                  message:
                      'Delete "${restaurant.name}"? This cannot be undone.',
                  confirmText: 'Delete',
                  isDestructive: true,
                );
                if (confirmed) {
                  await service.deleteRestaurant(restaurant.id);
                }
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Text(restaurant.isOpen ? 'Mark Closed' : 'Mark Open'),
            ),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete',
                  style: TextStyle(color: AppTheme.errorColor)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Add or edit restaurant screen - uses image URL instead of upload
class _AddEditRestaurantScreen extends StatefulWidget {
  final RestaurantModel? restaurant;

  const _AddEditRestaurantScreen({this.restaurant});

  @override
  State<_AddEditRestaurantScreen> createState() =>
      _AddEditRestaurantScreenState();
}

class _AddEditRestaurantScreenState extends State<_AddEditRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _imageController;
  late TextEditingController _ratingController;
  late TextEditingController _deliveryTimeController;
  late TextEditingController _deliveryFeeController;
  late TextEditingController _minOrderController;
  late TextEditingController _categoryController;
  final _firestoreService = FirestoreService();
  bool _isSaving = false;
  bool _isOpen = true;

  bool get _isEditing => widget.restaurant != null;

  @override
  void initState() {
    super.initState();
    final r = widget.restaurant;
    _nameController = TextEditingController(text: r?.name ?? '');
    _descController = TextEditingController(text: r?.description ?? '');
    _imageController = TextEditingController(text: r?.image ?? '');
    _ratingController = TextEditingController(
        text: r?.rating.toString() ?? '4.0');
    _deliveryTimeController =
        TextEditingController(text: r?.deliveryTime ?? '25-30 min');
    _deliveryFeeController = TextEditingController(
        text: r?.deliveryFee.toString() ?? '40');
    _minOrderController = TextEditingController(
        text: r?.minimumOrder.toString() ?? '99');
    _categoryController =
        TextEditingController(text: r?.category ?? '');
    _isOpen = r?.isOpen ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _imageController.dispose();
    _ratingController.dispose();
    _deliveryTimeController.dispose();
    _deliveryFeeController.dispose();
    _minOrderController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final restaurant = RestaurantModel(
      id: widget.restaurant?.id ?? '',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      image: _imageController.text.trim(),
      rating: double.tryParse(_ratingController.text) ?? 4.0,
      deliveryTime: _deliveryTimeController.text.trim(),
      deliveryFee: double.tryParse(_deliveryFeeController.text) ?? 40,
      minimumOrder: double.tryParse(_minOrderController.text) ?? 99,
      isOpen: _isOpen,
      category: _categoryController.text.trim(),
      createdAt: widget.restaurant?.createdAt ?? DateTime.now(),
    );

    try {
      if (_isEditing) {
        await _firestoreService.updateRestaurant(
          restaurant.id,
          restaurant.toFirestore(),
        );
      } else {
        await _firestoreService.addRestaurant(restaurant);
      }

      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          _isEditing
              ? 'Restaurant updated'
              : 'Restaurant added',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnackBar(context, 'Failed to save',
            isError: true);
      }
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Restaurant' : 'Add Restaurant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image URL input
              const Text(
                'Restaurant Image',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _imageController,
                hintText: 'Paste image URL (e.g., from Unsplash)',
                labelText: 'Image URL',
                prefixIcon: Icons.link,
              ),
              const SizedBox(height: 8),
              // Image preview
              if (_imageController.text.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: _imageController.text,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 120,
                        height: 120,
                        color: AppTheme.dividerColor,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                hintText: 'Restaurant name',
                labelText: 'Name',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descController,
                hintText: 'Description',
                labelText: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _categoryController,
                      hintText: 'Category',
                      labelText: 'Category',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _ratingController,
                      hintText: 'Rating',
                      labelText: 'Rating',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _deliveryTimeController,
                      hintText: 'e.g., 25-30 min',
                      labelText: 'Delivery Time',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _deliveryFeeController,
                      hintText: 'Fee',
                      labelText: 'Delivery Fee (₹)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _minOrderController,
                hintText: 'Minimum order amount',
                labelText: 'Minimum Order (₹)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Restaurant is open'),
                value: _isOpen,
                onChanged: (v) => setState(() => _isOpen = v),
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isEditing ? 'Update Restaurant' : 'Add Restaurant',
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
