class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Role Based Dashboards
  static const String superAdminDashboard = '/super-admin-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String vendorDashboard = '/vendor-dashboard';
  static const String customerHome = '/customer-home';
  static const String riderDashboard = '/rider-dashboard';

  // Admin Management Routes
  static const String vendors = '/vendors';
  static const String shops = '/shops';
  static const String assignShop = '/assign-shop';
  static const String customers = '/customers';
  static const String riders = '/riders';

  // Super Admin Specific Routes
  static const String categoryManagement = '/category-management';
  static const String shopBanners = '/shop-banners';
  static const String allShops = '/all-shops';
  static const String allProducts = '/all-products';
  static const String allOrders = '/all-orders';
  static const String complaints = '/complaints';
  static const String complaintDetails = '/complaint-details';
  static const String analytics = '/analytics';

  // Feature Routes
  static const String profile = '/profile';
  static const String products = '/products';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
}
