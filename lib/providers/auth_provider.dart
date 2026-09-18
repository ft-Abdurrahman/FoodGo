// File: lib/providers/auth_provider.dart
// Manages authentication state: login, signup, OTP, logout

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

/// Authentication states the app can be in
enum AuthStatus {
  uninitialized, // App just started
  authenticated, // User is logged in
  unauthenticated, // User is not logged in
  loading, // Auth operation in progress
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.uninitialized;
  User? _firebaseUser;
  UserModel? _userModel;
  String? _errorMessage;
  bool _isLoading = false;

  // Phone auth state
  String? _verificationId;
  String? _phoneNumber;

  // Getters
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAdmin => _userModel?.role == AppConstants.roleAdmin;
  String? get verificationId => _verificationId;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Initialize auth listener - call once at app startup
  void init() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        _firebaseUser = user;
        // Load user profile from Firestore
        _userModel = await _firestoreService.getUser(user.uid);
        _status = AuthStatus.authenticated;

        // Save FCM token for push notifications
        final token = await NotificationService().getToken();
        if (token != null) {
          await _firestoreService.updateUser(user.uid, {'fcmToken': token});
        }
      } else {
        _firebaseUser = null;
        _userModel = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  // ──────────────────────────────────────────────
  // Phone Authentication
  // ──────────────────────────────────────────────

  /// Send OTP to the given phone number
  Future<bool> sendOtp(String phoneNumber) async {
    _setLoading(true);
    _phoneNumber = phoneNumber;

    final result = await _authService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        _setLoading(false);
      },
      onVerificationComplete: (credential) async {
        await _handleAuthSuccess(credential);
      },
      onFailed: (e) {
        _errorMessage = AuthService.getAuthErrorMessage(e);
        _setLoading(false);
      },
      onCodeAutoRetrieved: (verificationId, token) {
        _verificationId = verificationId;
      },
    );

    return result != null;
  }

  /// Verify OTP entered by user
  Future<bool> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      _errorMessage = 'Please request a new OTP.';
      return false;
    }

    _setLoading(true);

    final credential = await _authService.verifyOtp(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    if (credential != null) {
      await _handleAuthSuccess(credential);
      return true;
    } else {
      _errorMessage = 'Invalid OTP. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  /// Handle successful authentication (create or load user profile)
  Future<void> _handleAuthSuccess(UserCredential credential) async {
    final user = credential.user;
    if (user == null) return;

    _firebaseUser = user;

    // Check if user already exists in Firestore
    final existingUser = await _firestoreService.getUser(user.uid);
    if (existingUser == null) {
      // New user - create profile
      final newUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email,
        phone: user.phoneNumber ?? _phoneNumber,
        role: AppConstants.roleCustomer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestoreService.createUser(newUser);
      _userModel = newUser;
    } else {
      _userModel = existingUser;
    }

    _status = AuthStatus.authenticated;
    _setLoading(false);
  }

  // ──────────────────────────────────────────────
  // Email Authentication
  // ──────────────────────────────────────────────

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    final credential = await _authService.signUpWithEmail(
      email: email,
      password: password,
    );

    if (credential?.user != null) {
      final user = credential!.user!;

      // Create user profile in Firestore
      final newUser = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        role: AppConstants.roleCustomer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestoreService.createUser(newUser);
      _userModel = newUser;
      _firebaseUser = user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } else {
      _errorMessage = 'Signup failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    final credential = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (credential?.user != null) {
      _firebaseUser = credential!.user!;
      _userModel = await _firestoreService.getUser(_firebaseUser!.uid);
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } else {
      _errorMessage = 'Invalid email or password.';
      _setLoading(false);
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    final success = await _authService.sendPasswordResetEmail(email);
    if (!success) {
      _errorMessage = 'Failed to send reset email.';
    }
    _setLoading(false);
    return success;
  }

  // ──────────────────────────────────────────────
  // Sign Out
  // ──────────────────────────────────────────────

  /// Sign out and clear all state
  Future<void> signOut() async {
    await _authService.signOut();
    _firebaseUser = null;
    _userModel = null;
    _status = AuthStatus.unauthenticated;
    _verificationId = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Update user model (e.g., after profile edit)
  void updateUserModel(UserModel updated) {
    _userModel = updated;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
