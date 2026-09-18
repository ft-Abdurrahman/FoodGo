// File: lib/models/address_model.dart
// Represents a delivery address stored as user subcollection

import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String label; // "Home", "Work", "Other"
  final String street;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  AddressModel({
    this.id = '',
    required this.label,
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  /// Full formatted address string
  String get fullAddress => '$street, $city, $state - $pincode';

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      label: data['label'] ?? 'Home',
      street: data['street'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      pincode: data['pincode'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }

  AddressModel copyWith({
    String? label,
    String? street,
    String? city,
    String? state,
    String? pincode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id,
      label: label ?? this.label,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
