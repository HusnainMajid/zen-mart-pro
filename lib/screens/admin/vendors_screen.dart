import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/vendor_model.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../utils/snackbar_helper.dart';
import 'admin_drawer.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProvider>().fetchVendors();
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
        title: const Text('Vendor Management'),
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
            child: Consumer<VendorProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.vendors.isEmpty) {
                  return const LoadingWidget();
                }

                if (provider.error != null && provider.vendors.isEmpty) {
                  return AppErrorWidget(
                    message: provider.error!,
                    onRetry: () => provider.fetchVendors(),
                  );
                }

                final filteredVendors = provider.vendors.where((vendor) {
                  return vendor.fullName.toLowerCase().contains(_searchQuery) ||
                      vendor.email.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredVendors.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No vendors found matching your search.',
                    icon: Icons.people_outline,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredVendors.length,
                  itemBuilder: (context, index) {
                    final vendor = filteredVendors[index];
                    return _VendorCard(
                      vendor: vendor,
                      onDelete: () => _confirmDelete(context, vendor),
                      onEdit: () => _showEditStatusDialog(context, vendor),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVendorDialog(context),
        label: const Text('Add Vendor'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, VendorModel vendor) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Vendor',
        content: 'Are you sure you want to delete ${vendor.fullName}? This action cannot be undone.',
        onConfirm: () async {
          try {
            await context.read<VendorProvider>().removeVendor(vendor.uid);
            if (!context.mounted) return;
            SnackBarHelper.showSuccess(context, 'Vendor deleted successfully');
          } catch (e) {
            if (!context.mounted) return;
            SnackBarHelper.showError(context, e.toString());
          }
        },
      ),
    );
  }

  void _showEditStatusDialog(BuildContext context, VendorModel vendor) {
    String selectedStatus = vendor.status;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Status: ${vendor.fullName}'),
          content: DropdownButtonFormField<String>(
            initialValue: selectedStatus,
            items: ['active', 'inactive', 'suspended']
                .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                .toList(),
            onChanged: (val) => setDialogState(() => selectedStatus = val!),
            decoration: const InputDecoration(labelText: 'Status'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<VendorProvider>().updateStatus(vendor.uid, selectedStatus);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  SnackBarHelper.showSuccess(context, 'Status updated');
                } catch (e) {
                  if (!context.mounted) return;
                  SnackBarHelper.showError(context, e.toString());
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVendorDialog(BuildContext context) {
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
          title: const Text('Add New Vendor'),
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
                    decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
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
                          await context.read<VendorProvider>().addVendor(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                fullName: nameController.text.trim(),
                                phone: phoneController.text.trim(),
                              );
                          if (!context.mounted) return;
                          context.pop();
                          _showCredentialsDialog(
                            context,
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          setDialogState(() => isSaving = false);
                          SnackBarHelper.showError(context, e.toString());
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
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Vendor Created'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please share these credentials with the vendor so they can log in:'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  _CredentialRow(label: 'Email', value: username),
                  const Divider(),
                  _CredentialRow(label: 'Password', value: password),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final VendorModel vendor;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _VendorCard({
    required this.vendor,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(vendor.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vendor.email),
            const SizedBox(height: 4),
            _StatusBadge(status: vendor.status),
          ],
        ),
        isThreeLine: true,
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
      case 'suspended':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  final String label;
  final String value;

  const _CredentialRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(
          child: SelectableText(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          onPressed: () {
            SnackBarHelper.showInfo(context, '$label copied to clipboard');
          },
        ),
      ],
    );
  }
}
