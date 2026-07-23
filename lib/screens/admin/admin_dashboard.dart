import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/routes/routes.dart';
import '../../providers/vendor_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/rider_provider.dart';
import '../../shared/widgets/loading_widget.dart';
import 'admin_drawer.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    // Fetch all counts
    await Future.wait([
      context.read<VendorProvider>().fetchVendors(),
      context.read<ShopProvider>().fetchShops(),
      context.read<CustomerProvider>().fetchCustomers(),
      context.read<RiderProvider>().fetchRiders(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      Consumer<VendorProvider>(
                        builder: (context, p, _) => _SummaryCard(
                          title: 'Total Vendors',
                          count: p.vendors.length.toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                          isLoading: p.isLoading,
                          onTap: () => context.push(Routes.vendors),
                        ),
                      ),
                      Consumer<ShopProvider>(
                        builder: (context, p, _) => _SummaryCard(
                          title: 'Total Shops',
                          count: p.shops.length.toString(),
                          icon: Icons.store,
                          color: Colors.green,
                          isLoading: p.isLoading,
                          onTap: () => context.push(Routes.shops),
                        ),
                      ),
                      Consumer<CustomerProvider>(
                        builder: (context, p, _) => _SummaryCard(
                          title: 'Total Customers',
                          count: p.customers.length.toString(),
                          icon: Icons.person_pin,
                          color: Colors.orange,
                          isLoading: p.isLoading,
                          onTap: () => context.push(Routes.customers),
                        ),
                      ),
                      Consumer<RiderProvider>(
                        builder: (context, p, _) => _SummaryCard(
                          title: 'Total Riders',
                          count: p.riders.length.toString(),
                          icon: Icons.delivery_dining,
                          color: Colors.purple,
                          isLoading: p.isLoading,
                          onTap: () => context.push(Routes.riders),
                        ),
                      ),
                      _SummaryCard(
                        title: 'Analytics',
                        count: 'View',
                        icon: Icons.analytics,
                        color: Colors.teal,
                        onTap: () => context.push(Routes.analytics),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _QuickActionButton(
                    icon: Icons.add_business,
                    label: 'Add Shop',
                    onTap: () => context.push(Routes.shops),
                  ),
                  const SizedBox(width: 12),
                  _QuickActionButton(
                    icon: Icons.person_add,
                    label: 'Add Vendor',
                    onTap: () => context.push(Routes.vendors),
                  ),
                  const SizedBox(width: 12),
                  _QuickActionButton(
                    icon: Icons.analytics,
                    label: 'Analytics',
                    onTap: () => context.push(Routes.analytics),
                  ),
                  const SizedBox(width: 12),
                  _QuickActionButton(
                    icon: Icons.shopping_bag,
                    label: 'Orders',
                    onTap: () => context.push(Routes.allOrders),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Recent Registered Vendors',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Consumer<VendorProvider>(
                  builder: (context, p, _) {
                    if (p.isLoading && p.vendors.isEmpty) return const SizedBox(height: 100, child: LoadingWidget());
                    if (p.vendors.isEmpty) return const ListTile(title: Text('No vendors yet'));
                    
                    final recentVendors = p.vendors.take(5).toList();
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentVendors.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final vendor = recentVendors[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text(vendor.fullName.isNotEmpty ? vendor.fullName[0] : '?')),
                          title: Text(vendor.fullName),
                          subtitle: Text(vendor.email),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(Routes.vendors),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withAlpha(50)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 12),
              if (isLoading)
                const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    count,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).primaryColor.withAlpha(75)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
