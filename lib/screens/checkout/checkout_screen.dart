// File: lib/screens/checkout/checkout_screen.dart
// Checkout screen with address selection, payment method, order summary, and place order

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/address_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../orders/order_tracking_screen.dart';
import '../profile/address_list_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = AppConstants.paymentCOD;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final userProvider = context.watch<UserProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final selectedAddress = userProvider.selectedAddress;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Delivery Address ──
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selectedAddress != null)
                    _buildAddressCard(selectedAddress, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddressListScreen(
                              isSelection: true),
                        ),
                      );
                    })
                  else
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AddressListScreen(isSelection: true),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.dividerColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add_location,
                                color: AppTheme.primaryColor),
                            SizedBox(width: 12),
                            Text('Add delivery address'),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // ── Payment Method ──
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    AppConstants.paymentCOD,
                    Icons.money,
                    'Pay when your order arrives',
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    AppConstants.paymentUPI,
                    Icons.account_balance_wallet,
                    'UPI / Google Pay / PhonePe',
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    AppConstants.paymentCard,
                    Icons.credit_card,
                    'Credit / Debit Card',
                  ),
                  const SizedBox(height: 24),
                  // ── Order Summary ──
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Column(
                      children: [
                        // Cart items
                        ...cart.items.map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.name} × ${item.quantity}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    AppHelpers.formatPrice(item.totalPrice),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 20),
                        _buildSummaryRow(
                            'Subtotal', AppHelpers.formatPrice(cart.subtotal)),
                        _buildSummaryRow(
                          'Delivery Fee',
                          cart.deliveryFee == 0
                              ? 'FREE'
                              : AppHelpers.formatPrice(cart.deliveryFee),
                          valueColor: cart.deliveryFee == 0
                              ? AppTheme.successColor
                              : null,
                        ),
                        const Divider(height: 20),
                        _buildSummaryRow(
                          'Total',
                          AppHelpers.formatPrice(cart.total),
                          isBold: true,
                          valueColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Place Order Button ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: CustomButton(
                text: 'Place Order • ${AppHelpers.formatPrice(cart.total)}',
                isLoading: orderProvider.isPlacing,
                onPressed: selectedAddress == null
                    ? null
                    : () => _placeOrder(context, cart, userProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(
    BuildContext context,
    CartProvider cart,
    UserProvider userProvider,
  ) async {
    final auth = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();
    final userId = auth.firebaseUser!.uid;
    final address = userProvider.selectedAddress!;

    final success = await orderProvider.placeOrder(
      userId: userId,
      restaurantId: cart.restaurantId!,
      restaurantName: cart.restaurantName!,
      items: cart.items,
      deliveryAddress: address,
      paymentMethod: _paymentMethod,
    );

    if (success && mounted) {
      // Clear cart after successful order
      cart.clearCart();
      // Navigate to order tracking
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/main',
        (route) => false,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(
            orderId: orderProvider.currentOrder!.id,
          ),
        ),
      );
    } else if (mounted) {
      AppHelpers.showSnackBar(
        context,
        orderProvider.error ?? 'Failed to place order',
        isError: true,
      );
    }
  }

  Widget _buildAddressCard(AddressModel address, VoidCallback onChange) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
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
          TextButton(
            onPressed: onChange,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      String method, IconData icon, String subtitle) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.05)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
