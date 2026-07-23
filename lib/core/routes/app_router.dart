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
import '../../screens/vendor/shop_profile_screen.dart';
import '../../screens/vendor/vendor_category_screen.dart';
import '../../screens/vendor/vendor_product_list_screen.dart';
import '../../screens/vendor/add_edit_product_screen.dart';
import '../../screens/vendor/vendor_order_list_screen.dart';
import '../../screens/vendor/vendor_order_details_screen.dart';
import '../../screens/vendor/vendor_reviews_screen.dart';
import '../../screens/vendor/vendor_reports_screen.dart';
import '../../screens/customer/customer_home.dart';
import '../../screens/customer/customer_main_nav.dart';
import '../../screens/customer/cart_screen.dart';
import '../../screens/customer/checkout_screen.dart';
import '../../screens/customer/order_tracking_screen.dart';
import '../../screens/customer/address_list_screen.dart';
import '../../screens/customer/wishlist_screen.dart';
import '../../screens/customer/notification_screen.dart';
import '../../screens/customer/product_details_screen.dart';
import '../../screens/customer/shop_details_screen.dart';
import '../../screens/customer/search_screen.dart';
import '../../screens/customer/edit_profile_screen.dart';
import '../../screens/rider/rider_dashboard.dart';
import '../../screens/admin/all_shops_screen.dart';
import '../../screens/admin/all_products_screen.dart';
import '../../screens/admin/all_orders_screen.dart';
import '../../screens/admin/order_details_screen.dart';
import '../../screens/admin/analytics_screen.dart';
import '../../models/order_model.dart';
import '../../models/complaint_model.dart';
import '../../models/product_model.dart';
import '../../models/shop_model.dart';
import '../../screens/admin/category_management_screen.dart';
import '../../screens/admin/complaint_list_screen.dart';
import '../../screens/admin/complaint_details_screen.dart';
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

      // 4. Role-based Access Control
      final role = user.role.toLowerCase();
      final location = state.matchedLocation;

      final vendorRoutes = [
        Routes.vendorDashboard,
        Routes.shopProfile,
        Routes.vendorCategories,
        Routes.vendorProducts,
        Routes.addProduct,
        Routes.editProduct,
        Routes.vendorOrders,
        Routes.vendorOrderDetails,
        Routes.vendorReviews,
        Routes.vendorReports,
      ];

      if (vendorRoutes.contains(location) && role != 'vendor') {
        return _getDashboardRoute(role);
      }

      // Customer specific routes protection
      final customerRoutes = [
        Routes.customerMain,
        Routes.cart,
        Routes.checkout,
        Routes.orderTracking,
        Routes.addresses,
        Routes.notifications,
      ];

      if (customerRoutes.contains(location) && role != 'customer') {
        return _getDashboardRoute(role);
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
        path: Routes.shopProfile,
        builder: (context, state) => const ShopProfileScreen(),
      ),
      GoRoute(
        path: Routes.vendorCategories,
        builder: (context, state) => const VendorCategoryScreen(),
      ),
      GoRoute(
        path: Routes.vendorProducts,
        builder: (context, state) => const VendorProductListScreen(),
      ),
      GoRoute(
        path: Routes.addProduct,
        builder: (context, state) => const AddEditProductScreen(),
      ),
      GoRoute(
        path: Routes.editProduct,
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return AddEditProductScreen(product: product);
        },
      ),
      GoRoute(
        path: Routes.vendorOrders,
        builder: (context, state) => const VendorOrderListScreen(),
      ),
      GoRoute(
        path: Routes.vendorOrderDetails,
        builder: (context, state) {
          final order = state.extra as OrderModel;
          return VendorOrderDetailsScreen(order: order);
        },
      ),
      GoRoute(
        path: Routes.vendorReviews,
        builder: (context, state) => const VendorReviewsScreen(),
      ),
      GoRoute(
        path: Routes.vendorReports,
        builder: (context, state) => const VendorReportsScreen(),
      ),
      GoRoute(
        path: Routes.customerHome,
        builder: (context, state) => const CustomerHome(),
      ),
      GoRoute(
        path: Routes.customerMain,
        builder: (context, state) => const CustomerMainNav(),
      ),
      GoRoute(
        path: Routes.shopDetails,
        builder: (context, state) {
          final shop = state.extra as ShopModel;
          return ShopDetailsScreen(shop: shop);
        },
      ),
      GoRoute(
        path: Routes.productDetails,
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return ProductDetailsScreen(product: product);
        },
      ),
      GoRoute(
        path: Routes.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: Routes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: Routes.orderTracking,
        builder: (context, state) {
          final order = state.extra as OrderModel?;
          return OrderTrackingScreen(order: order);
        },
      ),
      GoRoute(
        path: Routes.addresses,
        builder: (context, state) => const AddressListScreen(),
      ),
      GoRoute(
        path: Routes.wishlist,
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: Routes.search,
        builder: (context, state) {
          final query = state.extra as String?;
          return SearchScreen(initialQuery: query);
        },
      ),
      GoRoute(
        path: Routes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
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

      // Super Admin Features
      GoRoute(
        path: Routes.categoryManagement,
        builder: (context, state) => const CategoryManagementScreen(),
      ),
      GoRoute(
        path: Routes.allShops,
        builder: (context, state) => const AllShopsScreen(),
      ),
      GoRoute(
        path: Routes.allProducts,
        builder: (context, state) => const AllProductsScreen(),
      ),
      GoRoute(
        path: Routes.allOrders,
        builder: (context, state) => const AllOrdersScreen(),
      ),
      GoRoute(
        path: Routes.orderDetails,
        builder: (context, state) {
          final order = state.extra as OrderModel;
          return OrderDetailsScreen(order: order);
        },
      ),
      GoRoute(
        path: Routes.complaints,
        builder: (context, state) => const ComplaintListScreen(),
      ),
      GoRoute(
        path: Routes.complaintDetails,
        builder: (context, state) {
          final complaint = state.extra as ComplaintModel;
          return ComplaintDetailsScreen(complaint: complaint);
        },
      ),
      GoRoute(
        path: Routes.analytics,
        builder: (context, state) => const AnalyticsScreen(),
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
        return Routes.customerMain;
      case 'rider':
        return Routes.riderDashboard;
      default:
        return Routes.customerMain;
    }
  }
}
