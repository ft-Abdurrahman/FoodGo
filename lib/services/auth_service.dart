// File: lib/services/auth_service.dart
// Handles all Firebase Authentication operations: phone OTP, email/password, logout

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current Firebase user (null if not signed in)
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes - used to reactively update UI
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ──────────────────────────────────────────────
  // Phone Authentication (OTP)
  // ──────────────────────────────────────────────

  /// Send OTP to phone number
  /// Returns verificationId for later OTP verification
  Future<String?> sendOtp({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(PhoneAuthCredential) onVerificationComplete,
    required Function(FirebaseAuthException) onFailed,
    required Function(String, int?) onCodeAutoRetrieved,
  }) async {
    try {
      String? verificationId;

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        // OTP sent successfully - save verificationId for later use
        verificationCompleted: onVerificationComplete,
        // OTP sending failed
        verificationFailed: onFailed,
        // OTP sent - user needs to enter it manually
        codeSent: (String id, int? resendToken) {
          verificationId = id;
          onCodeSent(id);
        },
        // Auto-retrieval (works on some Android devices)
        codeAutoRetrievalTimeout: onCodeAutoRetrieved,
      );

      return verificationId;
    } on FirebaseAuthException catch (e) {
      onFailed(e);
      return null;
    }
  }

  /// Verify the OTP entered by user against the verificationId
  Future<UserCredential?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException {
      return null;
    }
  }

  // ──────────────────────────────────────────────
  // Email/Password Authentication
  // ──────────────────────────────────────────────

  /// Create new account with email and password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      return null;
    }
  }

  /// Sign in with existing email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      return null;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  /// Send email verification to current user
  Future<bool> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // Sign Out
  // ──────────────────────────────────────────────

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get user-friendly error message from Firebase auth exception
  static String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number. Please check and try again.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again.';
      case 'session-expired':
        return 'OTP session expired. Please request a new OTP.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
