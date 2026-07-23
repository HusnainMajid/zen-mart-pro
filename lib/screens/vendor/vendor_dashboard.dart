import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_dashboard_provider.dart';
import '../../providers/shop_provider.dart';
import '../../models/shop_model.dart';
import '../../models/product_model.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../core/routes/routes.dart';
import 'package:intl/intl.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  ShopModel? _shop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user != null && user.shopId != null) {
      context.read<VendorDashboardProvider>().listenToDashboardData(user.uid, user.shopId!);
      if (!mounted) return;
      final shop = await context.read<ShopProvider>().getShopById(user.shopId!);
      if (mounted) {
        setState(() {
          _shop = shop;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<VendorDashboardProvider>();
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.vendorReports),
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Reports',
          ),
          IconButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: dashboardProvider.isLoading || _shop == null
          ? const LoadingWidget()
          : dashboardProvider.errorMessage != null
              ? AppErrorWidget(
                  message: dashboardProvider.errorMessage!,
                  onRetry: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShopBanner(),
                        const SizedBox(height: 24),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        _buildStatsGrid(isTablet, dashboardProvider),
                        const SizedBox(height: 24),
                        _buildSalesPerformanceWidget(),
                        const SizedBox(height: 24),
                        _buildStockAlerts(dashboardProvider),
                        const SizedBox(height: 24),
                        _buildRecentOrders(dashboardProvider),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildShopBanner() {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withAlpha(200),
            ],
          ),
        ),
        child: Row(
          children: [
            Hero(
              tag: 'shop_logo',
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: Icon(Icons.store, size: 40, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _shop?.name ?? 'My Shop',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _shop?.address ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.push(Routes.shopProfile),
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'Edit Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildActionButton(
            context,
            'Orders',
            Icons.shopping_bag_outlined,
            Colors.blue,
            () => context.push(Routes.vendorOrders),
          ),
          _buildActionButton(
            context,
            'Reviews',
            Icons.star_outline,
            Colors.amber,
            () => context.push(Routes.vendorReviews),
          ),
          _buildActionButton(
            context,
            'Reports',
            Icons.bar_chart,
            Colors.green,
            () => context.push(Routes.vendorReports),
          ),
          _buildActionButton(
            context,
            'Products',
            Icons.inventory_2_outlined,
            Colors.purple,
            () => context.push(Routes.vendorProducts),
          ),
          _buildActionButton(
            context,
            'Categories',
            Icons.category_outlined,
            Colors.teal,
            () => context.push(Routes.vendorCategories),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(bool isTablet, VendorDashboardProvider provider) {
    final stats = provider.stats;
    if (stats == null) return const SizedBox.shrink();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Products', 
          stats.totalProducts.toString(), 
          Icons.inventory_2, 
          Colors.blue,
          onTap: () => context.push(Routes.vendorProducts),
        ),
        _buildStatCard(
          'Categories', 
          stats.totalCategories.toString(), 
          Icons.category, 
          Colors.orange,
          onTap: () => context.push(Routes.vendorCategories),
        ),
        _buildStatCard(
          'Pending Orders', 
          stats.pendingOrders.toString(), 
          Icons.pending_actions, 
          Colors.red,
          onTap: () => context.push(Routes.vendorOrders),
        ),
        _buildStatCard(
          'Revenue Today', 
          '\$${stats.revenueToday.toStringAsFixed(2)}', 
          Icons.today, 
          Colors.green,
          onTap: () => context.push(Routes.vendorReports),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesPerformanceWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sales Performance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Weekly Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.open_in_new, size: 18, color: Colors.blue),
                      onPressed: () => context.push(Routes.vendorReports),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 150,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 3),
                            FlSpot(1, 1),
                            FlSpot(2, 4),
                            FlSpot(3, 2),
                            FlSpot(4, 5),
                            FlSpot(5, 3),
                            FlSpot(6, 4),
                          ],
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withAlpha(51),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockAlerts(VendorDashboardProvider provider) {
    final List<ProductModel> products = provider.stats?.lowStockProducts ?? [];
    final outOfStock = products.where((p) => p.stock == 0).toList();
    final lowStock = products.where((p) => p.stock > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Stock Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (products.isNotEmpty)
              Text(
                '${products.length} Items',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (products.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[100]!),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('All products are in good stock', style: TextStyle(color: Colors.grey))),
            ),
          )
        else ...[
          if (outOfStock.isNotEmpty) ...[
            const Text('Out of Stock', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 8),
            ...outOfStock.map((p) => _buildStockItem(p, isCritical: true)),
            const SizedBox(height: 12),
          ],
          if (lowStock.isNotEmpty) ...[
            const Text('Low Stock', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 8),
            ...lowStock.map((p) => _buildStockItem(p, isCritical: false)),
          ],
        ],
      ],
    );
  }

  Widget _buildStockItem(ProductModel product, {required bool isCritical}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isCritical ? Colors.red.withAlpha(30) : Colors.orange.withAlpha(30)),
      ),
      child: ListTile(
        onTap: () => context.push(Routes.editProduct, extra: product),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.inventory_2, color: Colors.grey, size: 24),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('SKU: ${product.sku}', style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (isCritical ? Colors.red : Colors.orange).withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Stock: ${product.stock}',
            style: TextStyle(
              color: isCritical ? Colors.red : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders(VendorDashboardProvider provider) {
    final recentOrders = provider.stats?.recentOrders ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.push(Routes.vendorOrders),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recentOrders.isEmpty)
          const EmptyStateWidget(
            message: 'No orders found',
            icon: Icons.shopping_cart_outlined,
          )
        else
          ...recentOrders.map((order) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: ListTile(
                  onTap: () => context.push(Routes.vendorOrderDetails, extra: order),
                  title: Text('Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(
                    '${order.customerName} • ${DateFormat('MMM dd').format(order.orderTime)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getStatusColor(order.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
