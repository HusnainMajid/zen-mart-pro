import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../shared/widgets/loading_widget.dart';
import 'admin_drawer.dart';

class AssignShopScreen extends StatefulWidget {
  const AssignShopScreen({super.key});

  @override
  State<AssignShopScreen> createState() => _AssignShopScreenState();
}

class _AssignShopScreenState extends State<AssignShopScreen> {
  String? _selectedVendorId;
  String? _selectedShopId;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProvider>().fetchVendors();
      context.read<ShopProvider>().fetchShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Shop to Vendor'),
      ),
      drawer: const AdminDrawer(),
      body: Consumer2<VendorProvider, ShopProvider>(
        builder: (context, vProvider, sProvider, child) {
          if (vProvider.isLoading || sProvider.isLoading) {
            return const LoadingWidget();
          }

          // Vendors without a shop
          final availableVendors = vProvider.vendors
              .where((v) => v.shopId == null || v.shopId!.isEmpty)
              .toList();

          // Shops without an owner
          final availableShops = sProvider.shops
              .where((s) => s.ownerId.isEmpty || s.ownerId == 'unassigned')
              .toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.blue.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Select a vendor who doesn\'t have a shop and link them to an existing shop.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Step 1: Select Vendor', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    hintText: 'Choose a vendor...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  initialValue: _selectedVendorId,
                  items: availableVendors.map((v) {
                    return DropdownMenuItem(value: v.uid, child: Text(v.fullName));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedVendorId = value);
                  },
                ),
                const SizedBox(height: 24),
                const Text('Step 2: Select Shop', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    hintText: 'Choose a shop...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store),
                  ),
                  initialValue: _selectedShopId,
                  items: availableShops.map((s) {
                    return DropdownMenuItem(value: s.id, child: Text(s.name));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedShopId = value);
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: (_selectedVendorId != null && _selectedShopId != null && !_isAssigning)
                      ? _handleAssignment
                      : null,
                  child: _isAssigning
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Confirm Assignment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleAssignment() async {
    setState(() => _isAssigning = true);
    try {
      final shopProvider = context.read<ShopProvider>();
      final vendorProvider = context.read<VendorProvider>();
      
      await shopProvider.assignShop(_selectedShopId!, _selectedVendorId!);
      await vendorProvider.fetchVendors();
      
      if (!mounted) return;
      SnackBarHelper.showSuccess(context, 'Shop assigned successfully!');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }
}
