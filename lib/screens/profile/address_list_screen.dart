// File: lib/screens/profile/address_list_screen.dart
// List of user's delivery addresses with add/edit/delete

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/address_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../utils/helpers.dart';
import 'add_address_screen.dart';

class AddressListScreen extends StatelessWidget {
  final bool isSelection;

  const AddressListScreen({super.key, this.isSelection = false});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final addresses = userProvider.addresses;
    final userId = context.read<AuthProvider>().firebaseUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelection ? 'Select Address' : 'My Addresses'),
      ),
      body: addresses.isEmpty
          ? EmptyState(
              icon: Icons.location_on,
              title: 'No addresses yet',
              subtitle: 'Add a delivery address to get started',
              actionText: 'Add Address',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddAddressScreen(),
                  ),
                );
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _buildAddressCard(
                    context, address, userId, userProvider, isSelection);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddAddressScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address,
      String userId, UserProvider userProvider, bool isSelection) {
    final isSelected = userProvider.selectedAddress?.id == address.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected
          ? AppTheme.primaryColor.withOpacity(0.05)
          : null,
      child: InkWell(
        onTap: isSelection
            ? () {
                userProvider.selectAddress(address);
                Navigator.pop(context);
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                color: address.isDefault
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.fullAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddAddressScreen(address: address),
                        ),
                      );
                      break;
                    case 'default':
                      await userProvider.setDefaultAddress(
                          userId, address.id);
                      break;
                    case 'delete':
                      final confirmed =
                          await AppHelpers.showConfirmDialog(
                        context,
                        title: 'Delete Address',
                        message:
                            'Are you sure you want to delete this address?',
                        confirmText: 'Delete',
                        isDestructive: true,
                      );
                      if (confirmed) {
                        await userProvider.deleteAddress(
                            userId, address.id);
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  if (!address.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Text('Set as Default'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
