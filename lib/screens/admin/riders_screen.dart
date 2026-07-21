import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/rider_provider.dart';
import '../../models/rider_model.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../utils/snackbar_helper.dart';
import 'admin_drawer.dart';

class RidersScreen extends StatefulWidget {
  const RidersScreen({super.key});

  @override
  State<RidersScreen> createState() => _RidersScreenState();
}

class _RidersScreenState extends State<RidersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiderProvider>().fetchRiders();
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
        title: const Text('Rider Management'),
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search by name, email or phone...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: Consumer<RiderProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.riders.isEmpty) {
                  return const LoadingWidget();
                }

                if (provider.error != null && provider.riders.isEmpty) {
                  return AppErrorWidget(
                    message: provider.error!,
                    onRetry: () => provider.fetchRiders(),
                  );
                }

                final filteredRiders = provider.riders.where((rider) {
                  return rider.fullName.toLowerCase().contains(_searchQuery) ||
                      rider.email.toLowerCase().contains(_searchQuery) ||
                      rider.phone.contains(_searchQuery);
                }).toList();

                if (filteredRiders.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No riders found.',
                    icon: Icons.delivery_dining_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredRiders.length,
                  itemBuilder: (context, index) {
                    final rider = filteredRiders[index];
                    return _RiderCard(
                      rider: rider,
                      onDelete: () => _confirmDelete(context, rider),
                      onEdit: () => _showEditStatusDialog(context, rider),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRiderDialog(context),
        label: const Text('Add Rider'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, RiderModel rider) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Rider',
        content: 'Are you sure you want to delete ${rider.fullName}? This cannot be undone.',
        onConfirm: () async {
          try {
            await context.read<RiderProvider>().removeRider(rider.uid);
            if (mounted) SnackBarHelper.showSuccess(context, 'Rider deleted successfully');
          } catch (e) {
            if (mounted) SnackBarHelper.showError(context, e.toString());
          }
        },
      ),
    );
  }

  void _showEditStatusDialog(BuildContext context, RiderModel rider) {
    String selectedStatus = rider.status;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Update Status: ${rider.fullName}'),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            items: ['active', 'inactive', 'on_delivery']
                .map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase())))
                .toList(),
            onChanged: (val) => setDialogState(() => selectedStatus = val!),
            decoration: const InputDecoration(labelText: 'Status'),
          ),
          actions: [
            TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<RiderProvider>().updateStatus(rider.uid, selectedStatus);
                  if (mounted) {
                    context.pop();
                    SnackBarHelper.showSuccess(context, 'Rider status updated');
                  }
                } catch (e) {
                  if (mounted) SnackBarHelper.showError(context, e.toString());
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRiderDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Rider'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                    validator: (v) => v!.isEmpty ? 'Name required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    validator: (v) => v!.isEmpty ? 'Email required' : null,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                    validator: (v) => v!.isEmpty ? 'Phone required' : null,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Initial Password', prefixIcon: Icon(Icons.lock)),
                    validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => context.pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setDialogState(() => isSaving = true);
                        try {
                          await context.read<RiderProvider>().addRider(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                fullName: nameController.text.trim(),
                                phone: phoneController.text.trim(),
                              );
                          if (mounted) {
                            context.pop();
                            _showCredentialsDialog(
                              context,
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            setDialogState(() => isSaving = false);
                            SnackBarHelper.showError(context, e.toString());
                          }
                        }
                      }
                    },
              child: isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCredentialsDialog(BuildContext context, String username, String password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rider Account Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Credential Details:'),
            const SizedBox(height: 16),
            _CopyableField(label: 'Email', value: username),
            const SizedBox(height: 8),
            _CopyableField(label: 'Password', value: password),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _RiderCard extends StatelessWidget {
  final RiderModel rider;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _RiderCard({
    required this.rider,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: rider.profileImage.isNotEmpty ? NetworkImage(rider.profileImage) : null,
          child: rider.profileImage.isEmpty ? const Icon(Icons.delivery_dining) : null,
        ),
        title: Text(rider.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rider.email),
            const SizedBox(height: 4),
            _StatusBadge(status: rider.status),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'on_delivery':
        color = Colors.blue;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CopyableField extends StatelessWidget {
  final String label;
  final String value;

  const _CopyableField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Row(
          children: [
            Expanded(child: SelectableText(value, style: const TextStyle(fontWeight: FontWeight.bold))),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                SnackBarHelper.showInfo(context, '$label copied');
              },
            ),
          ],
        ),
      ],
    );
  }
}
