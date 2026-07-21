import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analytics_model.dart';

class AnalyticsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AnalyticsModel> getAnalytics() async {
    try {
      // Fetch data for aggregation
      final ordersSnapshot = await _db.collection('orders').get();

      double totalRevenue = 0.0;
      double monthlyRevenue = 0.0;
      int dailyOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      int pendingOrders = 0;

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfDay = DateTime(now.year, now.month, now.day);

      Map<String, int> shopOrderCount = {};
      Map<String, int> vendorOrderCount = {};
      Map<String, int> customerOrderCount = {};

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'pending';
        final total = (data['total'] ?? 0.0).toDouble();
        final orderTime = (data['orderTime'] as Timestamp).toDate();

        if (status == 'delivered') {
          completedOrders++;
          totalRevenue += total;
          if (orderTime.isAfter(startOfMonth)) {
            monthlyRevenue += total;
          }
        } else if (status == 'cancelled') {
          cancelledOrders++;
        } else if (status == 'pending') {
          pendingOrders++;
        }

        if (orderTime.isAfter(startOfDay)) {
          dailyOrders++;
        }

        // Aggregate for top lists
        String shopName = data['shopName'] ?? 'Unknown Shop';
        String vendorId = data['vendorId'] ?? 'Unknown Vendor';
        String customerName = data['customerName'] ?? 'Unknown Customer';

        shopOrderCount[shopName] = (shopOrderCount[shopName] ?? 0) + 1;
        vendorOrderCount[vendorId] = (vendorOrderCount[vendorId] ?? 0) + 1;
        customerOrderCount[customerName] = (customerOrderCount[customerName] ?? 0) + 1;
      }

      // Convert maps to sorted lists for top stats
      var topShops = shopOrderCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      var topVendors = vendorOrderCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      var topCustomers = customerOrderCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return AnalyticsModel(
        totalRevenue: totalRevenue,
        monthlyRevenue: monthlyRevenue,
        dailyOrders: dailyOrders,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
        pendingOrders: pendingOrders,
        topShops: topShops.take(5).map((e) => {'name': e.key, 'orders': e.value}).toList(),
        topVendors: topVendors.take(5).map((e) => {'id': e.key, 'orders': e.value}).toList(),
        topCustomers: topCustomers.take(5).map((e) => {'name': e.key, 'orders': e.value}).toList(),
      );
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to fetch analytics: $e';
    }
  }
}
