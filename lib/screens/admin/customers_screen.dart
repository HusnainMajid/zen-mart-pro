import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../models/user_model.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../utils/snackbar_helper.dart';
import 'admin_drawer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().fetchCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search by name or email...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.customers.isEmpty) {
                  return const LoadingWidget();
                }

                if (provider.error != null && provider.customers.isEmpty) {
                  return AppErrorWidget(
                    message: provider.error!,
                    onRetry: () => provider.fetchCustomers(),
                  );
                }

                final filteredCustomers = provider.customers.where((customer) {
                  return customer.fullName.toLowerCase().contains(_searchQuery) ||
                      customer.email.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No customers found.',
                    icon: Icons.person_search_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    return _CustomerCard(
                      customer: customer,
                      onToggleStatus: (value) => _confirmToggleStatus(context, customer, value),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmToggleStatus(BuildContext context, UserModel customer, bool newStatus) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: newStatus ? 'Activate Customer' : 'Deactivate Customer',
        content: 'Are you sure you want to ${newStatus ? 'activate' : 'deactivate'} ${customer.fullName}?',
        onConfirm: () async {
          try {
            await context.read<CustomerProvider>().toggleStatus(customer.uid, customer.isActive);
            if (mounted) SnackBarHelper.showSuccess(context, 'Customer ${newStatus ? 'activated' : 'deactivated'}');
          } catch (e) {
            if (mounted) SnackBarHelper.showError(context, e.toString());
          }
        },
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final UserModel customer;
  final Function(bool) onToggleStatus;

  const _CustomerCard({
    required this.customer,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: (customer.profileImage != null && customer.profileImage!.isNotEmpty)
              ? NetworkImage(customer.profileImage!)
              : null,
          child: (customer.profileImage == null || customer.profileImage!.isEmpty)
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer.email),
            Text(customer.phoneNumber, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch.adaptive(
              value: customer.isActive,
              onChanged: onToggleStatus,
              activeTrackColor: Colors.green,
            ),
            Text(
              customer.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 10,
                color: customer.isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
