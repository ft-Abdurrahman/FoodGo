// File: lib/screens/profile/add_address_screen.dart
// Add or edit a delivery address

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/address_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/helpers.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressModel? address; // If editing, pass existing address

  const AddAddressScreen({super.key, this.address});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  bool _isDefault = false;
  bool _isSaving = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _labelController = TextEditingController(text: a?.label ?? 'Home');
    _streetController = TextEditingController(text: a?.street ?? '');
    _cityController = TextEditingController(text: a?.city ?? '');
    _stateController = TextEditingController(text: a?.state ?? '');
    _pincodeController = TextEditingController(text: a?.pincode ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final userId = context.read<AuthProvider>().firebaseUser!.uid;
    final userProvider = context.read<UserProvider>();

    final address = AddressModel(
      id: widget.address?.id ?? '',
      label: _labelController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      isDefault: _isDefault,
    );

    bool success;
    if (_isEditing) {
      success = await userProvider.updateAddress(
          userId, widget.address!.id, address);
    } else {
      success = await userProvider.addAddress(userId, address);
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      AppHelpers.showSnackBar(
        context,
        _isEditing ? 'Address updated' : 'Address added',
      );
      Navigator.pop(context);
    } else if (mounted) {
      AppHelpers.showSnackBar(context, 'Failed to save address',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Address' : 'Add Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label (Home, Work, Other)
              const Text(
                'Address Label',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Home', 'Work', 'Other'].map((label) {
                  final isSelected = _labelController.text == label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _labelController.text = label);
                      },
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Street
              CustomTextField(
                controller: _streetController,
                hintText: 'Street address',
                labelText: 'Street',
                prefixIcon: Icons.home_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter street address' : null,
              ),
              const SizedBox(height: 16),
              // City
              CustomTextField(
                controller: _cityController,
                hintText: 'City',
                labelText: 'City',
                prefixIcon: Icons.location_city,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter city' : null,
              ),
              const SizedBox(height: 16),
              // State + Pincode
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      hintText: 'State',
                      labelText: 'State',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter state' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _pincodeController,
                      hintText: 'Pincode',
                      labelText: 'Pincode',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length != 6) return 'Must be 6 digits';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Default address toggle
              SwitchListTile(
                title: const Text('Set as default address'),
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isEditing ? 'Update Address' : 'Add Address',
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
