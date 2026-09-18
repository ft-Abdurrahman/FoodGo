// File: lib/screens/auth/phone_login_screen.dart
// Phone number input and OTP verification screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/helpers.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneFormKey = GlobalKey<FormState>();
  bool _otpSent = false;
  String _countryCode = '+91';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final phoneNumber = '$_countryCode${_phoneController.text.trim()}';

    final success = await auth.sendOtp(phoneNumber);
    if (success && mounted) {
      setState(() => _otpSent = true);
      AppHelpers.showSnackBar(context, 'OTP sent successfully!');
    } else if (mounted && auth.errorMessage != null) {
      AppHelpers.showSnackBar(context, auth.errorMessage!, isError: true);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length < 6) {
      AppHelpers.showSnackBar(context, 'Please enter the 6-digit OTP');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(_otpController.text.trim());

    if (success && mounted) {
      // Navigation handled by main.dart auth state listener
    } else if (mounted && auth.errorMessage != null) {
      AppHelpers.showSnackBar(context, auth.errorMessage!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _phoneFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  _otpSent ? 'Verify OTP' : 'Phone Number',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _otpSent
                      ? 'Enter the 6-digit code sent to ${_phoneController.text}'
                      : 'Enter your phone number to continue',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                if (!_otpSent) ...[
                  // Phone number input
                  Row(
                    children: [
                      // Country code
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: const Text(
                          '+91',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Phone number field
                      Expanded(
                        child: CustomTextField(
                          controller: _phoneController,
                          hintText: 'Enter phone number',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            if (value.length != 10) {
                              return 'Phone number must be 10 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Send OTP',
                    isLoading: auth.isLoading,
                    onPressed: _sendOtp,
                  ),
                ] else ...[
                  // OTP input
                  Center(
                    child: Pinput(
                      length: 6,
                      controller: _otpController,
                      defaultPinTheme: PinTheme(
                        width: 48,
                        height: 52,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 48,
                        height: 52,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Verify & Continue',
                    isLoading: auth.isLoading,
                    onPressed: _verifyOtp,
                  ),
                  const SizedBox(height: 16),
                  // Resend OTP
                  Center(
                    child: TextButton(
                      onPressed: _sendOtp,
                      child: const Text('Resend OTP'),
                    ),
                  ),
                  // Change phone number
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _otpSent = false),
                      child: const Text('Change Phone Number'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
