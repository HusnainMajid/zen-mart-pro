import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/routes/routes.dart';
import '../../providers/auth_provider.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.fullName ?? 'Admin'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          _DrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            route: Routes.superAdminDashboard,
            currentRoute: currentRoute,
          ),
          _DrawerItem(
            icon: Icons.people,
            title: 'Vendors',
            route: Routes.vendors,
            currentRoute: currentRoute,
          ),
          _DrawerItem(
            icon: Icons.store,
            title: 'Shops',
            route: Routes.shops,
            currentRoute: currentRoute,
          ),
          _DrawerItem(
            icon: Icons.person_pin,
            title: 'Customers',
            route: Routes.customers,
            currentRoute: currentRoute,
          ),
          _DrawerItem(
            icon: Icons.delivery_dining,
            title: 'Riders',
            route: Routes.riders,
            currentRoute: currentRoute,
          ),
          _DrawerItem(
            icon: Icons.analytics,
            title: 'Analytics & Reports',
            route: Routes.analytics,
            currentRoute: currentRoute,
          ),
          _DrawerItem(
            icon: Icons.shopping_bag,
            title: 'All Orders',
            route: Routes.allOrders,
            currentRoute: currentRoute,
          ),
          _DrawerItem(
            icon: Icons.inventory,
            title: 'All Products',
            route: Routes.allProducts,
            currentRoute: currentRoute,
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthProvider>().logout();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final String currentRoute;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : null),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        context.pop(); // Close drawer
        if (!isSelected) {
          context.go(route);
        }
      },
    );
  }
}
