import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_category_provider.dart';
import '../../providers/vendor_dashboard_provider.dart';
import '../../models/category_model.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../utils/snackbar_helper.dart';

class VendorCategoryScreen extends StatefulWidget {
  const VendorCategoryScreen({super.key});

  @override
  State<VendorCategoryScreen> createState() => _VendorCategoryScreenState();
}

class _VendorCategoryScreenState extends State<VendorCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<AuthProvider>().currentUser;
      if (user != null && user.shopId != null) {
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
    final provider = context.watch<VendorCategoryProvider>();
    final categories = provider.categories.where((c) => 
      c.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Categories'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search categories...',
              leading: const Icon(Icons.search),
              onChanged: (value) => setState(() => _searchQuery = value),
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128)),
            ),
          ),
        ),
      ),
      body: provider.isLoading
          ? const LoadingWidget()
          : provider.errorMessage != null
              ? AppErrorWidget(message: provider.errorMessage!, onRetry: _loadCategories)
              : categories.isEmpty
                  ? EmptyStateWidget(
                      message: _searchQuery.isEmpty ? 'No categories added yet' : 'No categories match your search',
                      icon: Icons.category_outlined,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _buildCategoryCard(category);
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        label: const Text('Add Category'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.category),
        ),
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(category.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showCategoryDialog(category: category),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(category),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCategoryDialog({CategoryModel? category}) async {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(text: category?.description ?? '');
    bool isSavingState = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Category' : 'Add New Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.category, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSavingState ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSavingState ? null : () async {
                if (nameController.text.isEmpty) {
                  SnackBarHelper.showError(context, 'Name is required');
                  return;
                }
                
                setDialogState(() => isSavingState = true);
                try {
                  final provider = context.read<VendorCategoryProvider>();
                  final auth = context.read<AuthProvider>();
                  final user = auth.currentUser!;

                  final newCategory = CategoryModel(
                    id: category?.id ?? '',
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    shopId: user.shopId,
                    createdAt: category?.createdAt ?? DateTime.now(),
                  );

                  bool success;
                  if (isEditing) {
                    success = await provider.updateCategory(newCategory);
                  } else {
                    success = await provider.addCategory(newCategory);
                  }

                  if (!mounted) return;
                  if (success) {
                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) SnackBarHelper.showSuccess(context, 'Category ${isEditing ? 'updated' : 'added'} successfully');
                    _refreshDashboard();
                  } else {
                    if (context.mounted) SnackBarHelper.showError(context, provider.errorMessage ?? 'Operation failed');
                  }
                } catch (e) {
                  if (mounted && context.mounted) SnackBarHelper.showError(context, e.toString());
                } finally {
                  if (mounted) setDialogState(() => isSavingState = false);
                }
              },
              child: isSavingState 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final user = context.read<AuthProvider>().currentUser!;
      final success = await context.read<VendorCategoryProvider>().deleteCategory(category.id, user.shopId!);
      if (success && mounted) {
        if (context.mounted) SnackBarHelper.showSuccess(context, 'Category deleted successfully');
        _refreshDashboard();
      } else if (mounted) {
        if (context.mounted) SnackBarHelper.showError(context, context.read<VendorCategoryProvider>().errorMessage ?? 'Failed to delete category');
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
