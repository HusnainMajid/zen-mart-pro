import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rider_order_provider.dart';
import '../../utils/snackbar_helper.dart';

class RiderDashboard extends StatefulWidget {
  const RiderDashboard({super.key});

  @override
  State<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends State<RiderDashboard> {
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiderOrderProvider>().listenToAvailableOrders();
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<RiderOrderProvider>().listenToMyDeliveries(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Implement refresh logic if needed
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?.fullName ?? 'Rider'}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Let\'s deliver some smiles today!',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  _buildOnlineStatusIndicator(),
                ],
              ),
              const SizedBox(height: 24),
              _buildStatusCard(context),
              const SizedBox(height: 24),
              _buildStatsGrid(context),
              const SizedBox(height: 32),
              _buildMyDeliveries(context),
              const SizedBox(height: 32),
              _buildAvailableRequests(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isOnline ? Colors.green.withAlpha(25) : Colors.red.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _isOnline ? Colors.green : Colors.red, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isOnline ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              color: _isOnline ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isOnline ? Colors.blue.withAlpha(20) : Colors.grey.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _isOnline ? Colors.blue.withAlpha(100) : Colors.grey.withAlpha(100), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: _isOnline ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delivery_dining, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isOnline ? 'Ready for Orders' : 'Currently Offline',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isOnline ? 'Waiting for new requests...' : 'Go online to start receiving orders',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.9,
              child: Switch.adaptive(
                value: _isOnline,
                activeTrackColor: Colors.blue.withAlpha(100),
                activeThumbColor: Colors.blue,
                onChanged: (val) {
                  setState(() {
                    _isOnline = val;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Consumer<RiderOrderProvider>(
      builder: (context, provider, _) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard(context, 'Active Orders', provider.activeDeliveriesCount.toString(), Icons.shopping_basket_outlined, Colors.orange),
            _buildStatCard(context, 'Delivered', provider.completedDeliveriesCount.toString(), Icons.task_alt, Colors.green),
            _buildStatCard(context, 'Earnings', '\$${provider.totalEarnings.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined, Colors.blue),
            _buildStatCard(context, 'Rating', '4.8', Icons.stars_outlined, Colors.purple),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Widget _buildMyDeliveries(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Active Deliveries',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Consumer<RiderOrderProvider>(
          builder: (context, provider, _) {
            if (provider.myDeliveries.isEmpty) {
              return _buildEmptyState('No active deliveries');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.myDeliveries.length,
              itemBuilder: (context, index) {
                final order = provider.myDeliveries[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('Order #${order.orderNumber}'),
                    subtitle: Text('Status: ${order.status.toUpperCase()}\nTo: ${order.deliveryAddress}'),
                    trailing: DropdownButton<String>(
                      hint: const Text('Update'),
                      items: ['accepted_by_rider', 'picked_up', 'out_for_delivery', 'delivered'].map((s) {
                        return DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase()));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          provider.updateStatus(order.id, val);
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvailableRequests(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Requests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {}, 
              child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold))
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!_isOnline)
          _buildEmptyState('Go online to see requests')
        else
          Consumer<RiderOrderProvider>(
            builder: (context, provider, _) {
              if (provider.availableOrders.isEmpty) {
                return _buildEmptyState('No pending requests found');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.availableOrders.length,
                itemBuilder: (context, index) {
                  final order = provider.availableOrders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text('Order #${order.orderNumber}'),
                      subtitle: Text('From: ${order.shopName}\nTo: ${order.deliveryAddress}'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          final user = context.read<AuthProvider>().currentUser;
                          if (user != null) {
                            final success = await provider.acceptDelivery(order.id, user.uid, user.fullName);
                          if (mounted) {
                            if (success) {
                              SnackBarHelper.showSuccess(context, 'Delivery accepted!');
                            } else {
                              SnackBarHelper.showError(context, provider.errorMessage ?? 'Failed to accept delivery');
                            }
                          }
                          }
                        },
                        child: const Text('Accept'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
