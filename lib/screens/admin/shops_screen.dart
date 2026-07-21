import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/routes/routes.dart';
import '../../providers/shop_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/shop_model.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../utils/snackbar_helper.dart';
import 'admin_drawer.dart';

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({super.key});

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().fetchShops();
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
        title: const Text('Shop Management'),
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search by shop name or location...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: Consumer<ShopProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.shops.isEmpty) {
                  return const LoadingWidget();
                }

                if (provider.error != null && provider.shops.isEmpty) {
                  return AppErrorWidget(
                    message: provider.error!,
                    onRetry: () => provider.fetchShops(),
                  );
                }

                final filteredShops = provider.shops.where((shop) {
                  return shop.name.toLowerCase().contains(_searchQuery) ||
                      shop.address.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredShops.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No shops found.',
                    icon: Icons.store_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredShops.length,
                  itemBuilder: (context, index) {
                    final shop = filteredShops[index];
                    return _ShopCard(
                      shop: shop,
                      onDelete: () => _confirmDelete(context, shop),
                      onEdit: () => _showAddShopDialog(context, shop: shop),
                      onAssign: () => context.push(Routes.assignShop),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddShopDialog(context),
        label: const Text('Add Shop'),
        icon: const Icon(Icons.add_business),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ShopModel shop) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Shop',
        content: 'Are you sure you want to delete ${shop.name}? This will also unlink the vendor.',
        onConfirm: () async {
          try {
            await context.read<ShopProvider>().removeShop(shop.id, shop.ownerId);
            if (!context.mounted) return;
            SnackBarHelper.showSuccess(context, 'Shop deleted successfully');
          } catch (e) {
            if (!context.mounted) return;
            SnackBarHelper.showError(context, e.toString());
          }
        },
      ),
    );
  }

  void _showAddShopDialog(BuildContext context, {ShopModel? shop}) {
    final isEditing = shop != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: shop?.name);
    final addressController = TextEditingController(text: shop?.address);
    final descController = TextEditingController(text: shop?.description);
    final contactController = TextEditingController(text: shop?.contact);
    String? selectedVendorId = shop?.ownerId;
    String status = shop?.status ?? 'pending';
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Shop' : 'Add New Shop'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Shop Name'),
                    validator: (v) => v!.isEmpty ? 'Name required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Location/Address'),
                    validator: (v) => v!.isEmpty ? 'Address required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contactController,
                    decoration: const InputDecoration(labelText: 'Contact Number'),
                    validator: (v) => v!.isEmpty ? 'Contact required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  if (!isEditing) ...[
                    const SizedBox(height: 12),
                    Consumer<VendorProvider>(
                      builder: (context, vProvider, _) {
                        final availableVendors = vProvider.vendors
                            .where((v) => v.shopId == null || v.shopId!.isEmpty)
                            .toList();

                        return DropdownButtonFormField<String>(
                          initialValue: selectedVendorId,
                          hint: const Text('Select Owner'),
                          items: availableVendors.map((v) {
                            return DropdownMenuItem(value: v.uid, child: Text(v.fullName));
                          }).toList(),
                          onChanged: (val) => setDialogState(() => selectedVendorId = val),
                          validator: (v) => v == null ? 'Please select a vendor' : null,
                        );
                      },
                    ),
                  ],
                  if (isEditing) ...[
                    const SizedBox(height: 12),
                     DropdownButtonFormField<String>(
                        initialValue: status,
                        items: ['pending', 'active', 'inactive']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                            .toList(),
                        onChanged: (val) => setDialogState(() => status = val!),
                        decoration: const InputDecoration(labelText: 'Status'),
                      ),
                  ],
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
                          final shopData = ShopModel(
                            id: shop?.id ?? '',
                            name: nameController.text.trim(),
                            address: addressController.text.trim(),
                            description: descController.text.trim(),
                            contact: contactController.text.trim(),
                            banner: shop?.banner ?? '',
                            logo: shop?.logo ?? '',
                            ownerId: selectedVendorId!,
                            status: status,
                            createdAt: shop?.createdAt ?? DateTime.now(),
                          );

                          if (isEditing) {
                            await context.read<ShopProvider>().updateShop(shopData);
                          } else {
                            await context.read<ShopProvider>().addShop(shopData);
                          }

                          if (!context.mounted) return;
                          context.pop();
                          SnackBarHelper.showSuccess(context, 'Shop ${isEditing ? 'updated' : 'created'} successfully');
                        } catch (e) {
                          if (!context.mounted) return;
                          setDialogState(() => isSaving = false);
                          SnackBarHelper.showError(context, e.toString());
                        }
                      }
                    },
              child: isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onAssign;

  const _ShopCard({
    required this.shop,
    required this.onDelete,
    required this.onEdit,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: shop.logo.isNotEmpty 
                    ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(shop.logo, fit: BoxFit.cover))
                    : const Icon(Icons.store, color: Colors.grey),
              ),
              title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(shop.address),
              trailing: _StatusBadge(status: shop.status),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onAssign,
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Reassign'),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
              ],
            )
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
      case 'pending':
        color = Colors.orange;
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
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
