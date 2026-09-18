// File: lib/screens/profile/edit_profile_screen.dart
// Edit user profile: name, phone (no image upload - uses default avatar)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/helpers.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().userModel;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final uid = auth.firebaseUser!.uid;

    setState(() => _isSaving = true);

    // Update name and phone
    final success = await userProvider.updateProfile(
      uid: uid,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      // Update auth provider's user model
      auth.updateUserModel(
        auth.userModel!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      );
      AppHelpers.showSnackBar(context, 'Profile updated successfully');
      Navigator.pop(context);
    } else if (mounted) {
      AppHelpers.showSnackBar(context, 'Failed to update profile',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile avatar (default icon - no upload)
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(Icons.person,
                  size: 40, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 32),
            // Name
            CustomTextField(
              controller: _nameController,
              hintText: 'Enter your name',
              labelText: 'Full Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            // Email (read-only)
            CustomTextField(
              controller: TextEditingController(text: user?.email ?? ''),
              hintText: 'Email',
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            // Phone
            CustomTextField(
              controller: _phoneController,
              hintText: 'Enter phone number',
              labelText: 'Phone',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Save Changes',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
