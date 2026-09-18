// File: lib/providers/user_provider.dart
// Manages user profile state: loading profile, updating profile, addresses

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';
import '../services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _user;
  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get user => _user;
  List<AddressModel> get addresses => _addresses;
  AddressModel? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load user profile from Firestore
  Future<void> loadUserProfile(String uid) async {
    _setLoading(true);
    try {
      _user = await _firestoreService.getUser(uid);
    } catch (e) {
      _error = 'Failed to load profile.';
    }
    _setLoading(false);
  }

  /// Update user profile (name, phone, etc.)
  Future<bool> updateProfile({
    required String uid,
    String? name,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;

      await _firestoreService.updateUser(uid, updates);
      _user = _user?.copyWith(name: name, phone: phone);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to update profile.';
      _setLoading(false);
      return false;
    }
  }

  /// Load user's addresses
  void listenToAddresses(String userId) {
    _firestoreService.getAddresses(userId).listen((addresses) {
      _addresses = addresses;
      // Auto-select default address
      _selectedAddress =
          addresses.where((a) => a.isDefault).isNotEmpty
              ? addresses.firstWhere((a) => a.isDefault)
              : addresses.isNotEmpty
                  ? addresses.first
                  : null;
      notifyListeners();
    });
  }

  /// Add new address
  Future<bool> addAddress(String userId, AddressModel address) async {
    try {
      await _firestoreService.addAddress(userId, address);
      return true;
    } catch (e) {
      _error = 'Failed to add address.';
      return false;
    }
  }

  /// Update existing address
  Future<bool> updateAddress(
      String userId, String addressId, AddressModel address) async {
    try {
      await _firestoreService.updateAddress(userId, addressId, address);
      return true;
    } catch (e) {
      _error = 'Failed to update address.';
      return false;
    }
  }

  /// Delete address
  Future<bool> deleteAddress(String userId, String addressId) async {
    try {
      await _firestoreService.deleteAddress(userId, addressId);
      return true;
    } catch (e) {
      _error = 'Failed to delete address.';
      return false;
    }
  }

  /// Set address as default
  Future<bool> setDefaultAddress(String userId, String addressId) async {
    try {
      await _firestoreService.setDefaultAddress(userId, addressId);
      return true;
    } catch (e) {
      _error = 'Failed to set default address.';
      return false;
    }
  }

  /// Select address for checkout
  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
