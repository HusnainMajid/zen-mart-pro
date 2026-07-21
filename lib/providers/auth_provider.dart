import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // Hardcoded Super Admin Credentials
  static const String _superAdminEmail = 'admin@zenmartpro.com';
  static const String _superAdminPassword = 'Admin@123';

  // Check Authentication State on App Launch
  Future<void> checkAuthState() async {
    _setLoading(true);
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        await _fetchAndSetUser(firebaseUser.uid);
      }
    } catch (e) {
      debugPrint('Error checking auth state: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Login Method
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final credential = await _authService.signIn(email, password);
      final uid = credential.user!.uid;

      try {
        // Check if it's the hardcoded Super Admin by email
        if (email.toLowerCase() == _superAdminEmail) {
          UserModel? user = await _firestoreService.getUser(uid);
          if (user == null || user.role != 'super_admin') {
            user = UserModel(
              uid: uid,
              fullName: 'Super Admin',
              email: _superAdminEmail,
              phoneNumber: '',
              role: 'super_admin',
              createdAt: DateTime.now(),
              lastLogin: DateTime.now(),
              isActive: true,
              isVerified: true,
            );
            await _firestoreService.saveUser(user);
          }
          _currentUser = user;
        } else {
          await _fetchAndSetUser(uid);
        }

        if (_currentUser != null) {
          await _firestoreService.updateLastLogin(_currentUser!.uid);
        }
      } catch (firestoreError) {
        debugPrint('Firestore login error: $firestoreError');
        // If firestore fails but auth succeeded, we still have a partial failure
        throw 'Authenticated successfully, but failed to load profile: $firestoreError';
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Register Customer Method
  Future<void> registerCustomer({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    try {
      final credential = await _authService.signUp(email, password);
      final uid = credential.user!.uid;

      final newUser = UserModel(
        uid: uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        role: 'customer',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        isActive: true,
        isVerified: false,
      );

      try {
        await _firestoreService.saveUser(newUser);
        await _authService.sendEmailVerification();
      } catch (firestoreError) {
        throw 'Account created, but failed to save profile: $firestoreError';
      }

      _currentUser = newUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Logout Method
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Internal helper to fetch user data
  Future<void> _fetchAndSetUser(String uid) async {
    final user = await _firestoreService.getUser(uid);
    if (user != null) {
      _currentUser = user;
    } else {
      // Handle case where user exists in Auth but not Firestore
      // This shouldn't happen normally in a clean flow
      _currentUser = null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
