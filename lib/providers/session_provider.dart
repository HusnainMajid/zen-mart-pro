import 'package:flutter/material.dart';
import 'auth_provider.dart';

class SessionProvider with ChangeNotifier {
  AuthProvider _authProvider;
  bool _isInitialized = false;

  SessionProvider(this._authProvider);

  bool get isInitialized => _isInitialized;
  AuthProvider get authProvider => _authProvider;

  // Allow updating the dependency without resetting state
  void update(AuthProvider auth) {
    _authProvider = auth;
  }

  // Initialize the session
  Future<void> initializeApp() async {
    if (_isInitialized) return;

    try {
      // Check auth state to see if user is already logged in
      await authProvider.checkAuthState();
      // Optional: Add a small delay to ensure splash is visible for branding
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Session initialization error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Determine the landing screen based on session state
  bool get isLoggedIn => authProvider.currentUser != null;
  
  String? get userRole => authProvider.currentUser?.role;

  bool get isSuperAdmin => userRole == 'super_admin';
  bool get isAdmin => userRole == 'admin';
  bool get isCustomer => userRole == 'customer';
}
