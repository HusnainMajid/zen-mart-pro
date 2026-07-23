import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_product_provider.dart';
import '../../providers/vendor_category_provider.dart';
import '../../providers/vendor_dashboard_provider.dart';
import '../../models/product_model.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/primary_button.dart';
import '../../utils/snackbar_helper.dart';

class VendorProductListScreen extends StatefulWidget {
  const VendorProductListScreen({super.key});

  @override
  State<VendorProductListScreen> createState() => _VendorProductListScreenState();
}

class _VendorProductListScreenState extends State<VendorProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<AuthProvider>().currentUser;
      if (user != null && user.shopId != null) {
        context.read<VendorProductProvider>().fetchShopProducts(user.shopId!);
        context.read<VendorCategoryProvider>().fetchShopCategories(user.shopId!);
      }
    });
  }

  void _refreshDashboard() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null && user.shopId != null) {
      context.read<VendorDashboardProvider>().fetchDashboardData(user.uid, user.shopId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(provider),
          Expanded(
            child: _buildProductList(provider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.addProduct),
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar(VendorProductProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchBar(
        controller: _searchController,
        hintText: 'Search by name or SKU...',
        leading: const Icon(Icons.search),
        onChanged: (value) => provider.setSearchQuery(value),
        trailing: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                provider.setSearchQuery('');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProductList(VendorProductProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const LoadingWidget();
    }

    if (provider.errorMessage != null && provider.products.isEmpty) {
      return AppErrorWidget(
        message: provider.errorMessage!,
        onRetry: _loadData,
      );
    }

    if (provider.products.isEmpty) {
      return EmptyStateWidget(
        message: provider.searchQuery.isEmpty 
            ? 'No products added yet' 
            : 'No products match your search',
        icon: Icons.inventory_2_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        final product = provider.products[index];
        return _ProductListItem(
          product: product,
          onEdit: () async {
             await context.push(Routes.editProduct, extra: product);
             _loadData();
             _refreshDashboard();
          },
          onDelete: () => _confirmDelete(product),
          onDuplicate: () => _handleDuplicate(product),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _FilterBottomSheet(),
    );
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Product',
        content: 'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
        onConfirm: () {}, // Handled by dialog pop result
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<VendorProductProvider>().deleteProduct(product);
      if (success && mounted) {
        SnackBarHelper.showSuccess(context, 'Product deleted successfully');
        _refreshDashboard();
      } else if (mounted) {
        SnackBarHelper.showError(context, context.read<VendorProductProvider>().errorMessage ?? 'Delete failed');
      }
    }
  }

  Future<void> _handleDuplicate(ProductModel product) async {
    final success = await context.read<VendorProductProvider>().duplicateProduct(product);
    if (success && mounted) {
      SnackBarHelper.showSuccess(context, 'Product duplicated successfully');
      _refreshDashboard();
    } else if (mounted) {
      SnackBarHelper.showError(context, context.read<VendorProductProvider>().errorMessage ?? 'Duplicate failed');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ProductListItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const _ProductListItem({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stock == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2, color: Colors.grey, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${product.sku}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (product.discountPrice != null && product.discountPrice! > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '\$${product.discountPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildStockBadge(context, isOutOfStock),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit': onEdit(); break;
                    case 'duplicate': onDuplicate(); break;
                    case 'delete': onDelete(); break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                  const PopupMenuItem(value: 'duplicate', child: Row(children: [Icon(Icons.copy, size: 18), SizedBox(width: 8), Text('Duplicate')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockBadge(BuildContext context, bool isOutOfStock) {
    String label = 'In Stock: ${product.stock}';
    Color color = Colors.green;

    if (isOutOfStock) {
      label = 'Out of Stock';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(75)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String? _selectedCategoryId;
  String _stockStatus = 'all';

  @override
  void initState() {
    super.initState();
    final provider = context.read<VendorProductProvider>();
    _selectedCategoryId = provider.selectedCategory;
    _stockStatus = provider.stockStatus;
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<VendorCategoryProvider>().categories;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  context.read<VendorProductProvider>().clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            hint: const Text('All Categories'),
            items: [
              const DropdownMenuItem(value: 'all', child: Text('All Categories')),
              ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
            ],
            onChanged: (val) => setState(() => _selectedCategoryId = val == 'all' ? null : val),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const Text('Stock Status', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(label: 'All', value: 'all', groupValue: _stockStatus, onSelected: (v) => setState(() => _stockStatus = v)),
              _FilterChip(label: 'In Stock', value: 'in_stock', groupValue: _stockStatus, onSelected: (v) => setState(() => _stockStatus = v)),
              _FilterChip(label: 'Out of Stock', value: 'out_of_stock', groupValue: _stockStatus, onSelected: (v) => setState(() => _stockStatus = v)),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Apply Filters',
            onPressed: () {
              context.read<VendorProductProvider>().setFilters(
                categoryId: _selectedCategoryId,
                stockStatus: _stockStatus,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final Function(String) onSelected;

  const _FilterChip({required this.label, required this.value, required this.groupValue, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: groupValue == value,
      onSelected: (_) => onSelected(value),
    );
  }
}
