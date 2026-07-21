import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/admin/admin_dashboard.dart';
import '../../screens/admin/vendors_screen.dart';
import '../../screens/admin/shops_screen.dart';
import '../../screens/admin/assign_shop_screen.dart';
import '../../screens/admin/customers_screen.dart';
import '../../screens/admin/riders_screen.dart';
import '../../screens/vendor/vendor_dashboard.dart';
import '../../screens/customer/customer_home.dart';
import '../../screens/rider/rider_dashboard.dart';
import 'routes.dart';

class AppRouter {
  final AuthProvider authProvider;
  final SessionProvider sessionProvider;

  AppRouter(this.authProvider, this.sessionProvider);

  late final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: Listenable.merge([authProvider, sessionProvider]),
    redirect: (context, state) {
      // 1. Wait for session initialization
      if (!sessionProvider.isInitialized) {
        return null; // Stay on initialLocation (Splash)
      }

      final user = authProvider.currentUser;
      final bool isAuthenticated = user != null;
      final bool isLoading = authProvider.isLoading;

      if (isLoading) return null;

      final isSplash = state.matchedLocation == Routes.splash;
      final isLogin = state.matchedLocation == Routes.login;
      final isRegister = state.matchedLocation == Routes.register;
      final isForgotPassword = state.matchedLocation == Routes.forgotPassword;
      
      final isAuthRoute = isLogin || isRegister || isForgotPassword;

      // 2. If not authenticated
      if (!isAuthenticated) {
        // Allow access to auth routes
        if (isAuthRoute) return null;
        // Redirect everything else (including splash) to login
        return Routes.login;
      }

      // 3. If authenticated
      // If user is on splash or auth routes, redirect to their dashboard
      if (isSplash || isAuthRoute) {
        return _getDashboardRoute(user.role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: Routes.adminDashboard,
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: Routes.vendorDashboard,
        builder: (context, state) => const VendorDashboard(),
      ),
      GoRoute(
        path: Routes.customerHome,
        builder: (context, state) => const CustomerHome(),
      ),
      GoRoute(
        path: Routes.riderDashboard,
        builder: (context, state) => const RiderDashboard(),
      ),
      GoRoute(
        path: Routes.superAdminDashboard,
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: Routes.vendors,
        builder: (context, state) => const VendorsScreen(),
      ),
      GoRoute(
        path: Routes.shops,
        builder: (context, state) => const ShopsScreen(),
      ),
      GoRoute(
        path: Routes.assignShop,
        builder: (context, state) => const AssignShopScreen(),
      ),
      GoRoute(
        path: Routes.customers,
        builder: (context, state) => const CustomersScreen(),
      ),
      GoRoute(
        path: Routes.riders,
        builder: (context, state) => const RidersScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page not found'),
            TextButton(
              onPressed: () => context.go(Routes.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  String _getDashboardRoute(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
      case 'super admin':
        return Routes.superAdminDashboard;
      case 'admin':
        return Routes.adminDashboard;
      case 'vendor':
        return Routes.vendorDashboard;
      case 'customer':
        return Routes.customerHome;
      case 'rider':
        return Routes.riderDashboard;
      default:
        return Routes.customerHome;
    }
  }
}
