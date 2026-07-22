import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_category_provider.dart';
import '../../models/category_model.dart';
import '../../services/storage_service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  void _loadCategories() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null && user.shopId != null) {
      context.read<VendorCategoryProvider>().fetchShopCategories(user.shopId!);
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
        leading: CircleAvatar(
          backgroundImage: category.iconUrl.isNotEmpty
              ? CachedNetworkImageProvider(category.iconUrl)
              : null,
          child: category.iconUrl.isEmpty ? const Icon(Icons.category) : null,
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
    String status = category?.status ?? 'active';
    File? imageFile;
    bool isSaving = false;

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
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setDialogState(() => imageFile = File(picked.path));
                    }
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      image: imageFile != null
                          ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover)
                          : (category?.iconUrl.isNotEmpty ?? false)
                              ? DecorationImage(image: CachedNetworkImageProvider(category!.iconUrl), fit: BoxFit.cover)
                              : null,
                    ),
                    child: (imageFile == null && (category?.iconUrl.isEmpty ?? true))
                        ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
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
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (val) => setDialogState(() => status = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (nameController.text.isEmpty) {
                  SnackBarHelper.showError(context, 'Name is required');
                  return;
                }
                
                setDialogState(() => isSaving = true);
                try {
                  final provider = context.read<VendorCategoryProvider>();
                  final auth = context.read<AuthProvider>();
                  final user = auth.currentUser!;
                  String imageUrl = category?.iconUrl ?? '';

                  if (imageFile != null) {
                    imageUrl = await StorageService().uploadImage(
                      imageFile!,
                      'categories/${user.shopId}/${DateTime.now().millisecondsSinceEpoch}.jpg',
                    );
                  }

                  final newCategory = CategoryModel(
                    id: category?.id ?? '',
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    iconUrl: imageUrl,
                    shopId: user.shopId,
                    displayOrder: category?.displayOrder ?? 0,
                    status: status,
                    isActive: status == 'active',
                    createdAt: category?.createdAt ?? DateTime.now(),
                  );

                  bool success;
                  if (isEditing) {
                    success = await provider.updateCategory(newCategory);
                  } else {
                    success = await provider.addCategory(newCategory);
                  }

                  if (success && context.mounted) {
                    Navigator.pop(context);
                    SnackBarHelper.showSuccess(context, 'Category ${isEditing ? 'updated' : 'added'} successfully');
                  } else if (context.mounted) {
                    SnackBarHelper.showError(context, provider.errorMessage ?? 'Operation failed');
                  }
                } catch (e) {
                  if (context.mounted) SnackBarHelper.showError(context, e.toString());
                } finally {
                  setDialogState(() => isSaving = false);
                }
              },
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<VendorCategoryProvider>();
    
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true && context.mounted) {
      final scaffoldContext = context;
      final user = auth.currentUser!;
      final success = await provider.deleteCategory(category.id, user.shopId!);
      if (success && scaffoldContext.mounted) {
        SnackBarHelper.showSuccess(scaffoldContext, 'Category deleted successfully');
      } else if (scaffoldContext.mounted) {
        SnackBarHelper.showError(scaffoldContext, provider.errorMessage ?? 'Failed to delete category');
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
