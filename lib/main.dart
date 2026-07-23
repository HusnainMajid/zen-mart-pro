import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme.dart';
import 'core/routes/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/session_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/rider_provider.dart';
import 'providers/category_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/admin_product_provider.dart';
import 'providers/admin_order_provider.dart';
import 'providers/vendor_product_provider.dart';
import 'providers/vendor_category_provider.dart';
import 'providers/vendor_dashboard_provider.dart';
import 'providers/vendor_order_provider.dart';
import 'providers/vendor_review_provider.dart';
import 'providers/vendor_report_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/address_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/customer_order_provider.dart';
import 'providers/rider_order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool isFirebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(MyApp(isFirebaseInitialized: isFirebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool isFirebaseInitialized;
  
  const MyApp({super.key, required this.isFirebaseInitialized});

  @override
  Widget build(BuildContext context) {
    if (!isFirebaseInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Configuration Error',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Firebase could not be initialized. Please check your google-services.json and internet connection.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => main(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => RiderProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => AdminProductProvider()),
        ChangeNotifierProvider(create: (_) => AdminOrderProvider()),
        ChangeNotifierProvider(create: (_) => VendorProductProvider()),
        ChangeNotifierProvider(create: (_) => VendorCategoryProvider()),
        ChangeNotifierProvider(create: (_) => VendorDashboardProvider()),
        ChangeNotifierProvider(create: (_) => VendorOrderProvider()),
        ChangeNotifierProvider(create: (_) => VendorReviewProvider()),
        ChangeNotifierProvider(create: (_) => VendorReportProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CustomerOrderProvider()),
        ChangeNotifierProvider(create: (_) => RiderOrderProvider()),
        ChangeNotifierProxyProvider<AuthProvider, SessionProvider>(
          create: (context) => SessionProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => previous!..update(auth),
        ),
        ProxyProvider2<AuthProvider, SessionProvider, AppRouter>(
          create: (context) => AppRouter(
            context.read<AuthProvider>(),
            context.read<SessionProvider>(),
          ),
          update: (context, auth, session, previous) => previous ?? AppRouter(auth, session),
        ),
      ],
      child: const ZenMartApp(),
    );
  }
}

class ZenMartApp extends StatefulWidget {
  const ZenMartApp({super.key});

  @override
  State<ZenMartApp> createState() => _ZenMartAppState();
}

class _ZenMartAppState extends State<ZenMartApp> {
  @override
  void initState() {
    super.initState();
    // Initialize session after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SessionProvider>().initializeApp();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = context.read<AppRouter>().router;

    return MaterialApp.router(
      title: 'Zen Mart Pro',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
