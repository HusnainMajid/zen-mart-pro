import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_product_provider.dart';
import '../../providers/vendor_category_provider.dart';
import '../../providers/shop_provider.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../utils/snackbar_helper.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _skuController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController(text: '5');

  // Selection states
  CategoryModel? _selectedCategory;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.product!;
      _nameController.text = p.name;
      _descController.text = p.description;
      _priceController.text = p.price.toString();
      _discountPriceController.text = p.discountPrice?.toString() ?? '';
      _skuController.text = p.sku;
      _stockController.text = p.stock.toString();
      _minStockController.text = p.minStockAlert.toString();
      
      // Load categories and match selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final categories = context.read<VendorCategoryProvider>().categories;
        if (categories.isNotEmpty) {
          setState(() {
            _selectedCategory = categories.cast<CategoryModel?>().firstWhere(
              (c) => c?.id == p.categoryId,
              orElse: () => null,
            );
          });
        }
      });
    }
  }

  void _generateSKU() {
    if (_selectedCategory == null) {
      SnackBarHelper.showInfo(context, 'Please select a category first');
      return;
    }
    
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user == null || user.shopId == null) {
      SnackBarHelper.showError(context, 'Shop information not found.');
      return;
    }

    // Try to get shop name from provider if loaded, otherwise use generic prefix
    String shopName = 'ZN';
    try {
      final shop = context.read<ShopProvider>().shops.firstWhere((s) => s.id == user.shopId);
      shopName = shop.name;
    } catch (_) {
      // Shop details not in list, use fallback
    }
    
    final sku = context.read<VendorProductProvider>().generateSKU(_selectedCategory!.name, shopName);
    setState(() => _skuController.text = sku);
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      SnackBarHelper.showError(context, 'Please select a category');
      return;
    }

    final user = context.read<AuthProvider>().currentUser;
    if (user == null || user.shopId == null) {
      SnackBarHelper.showError(context, 'User session expired or shop not assigned');
      return;
    }

    // Try to get shop name
    String shopName = 'ZN Shop';
    try {
      final shop = context.read<ShopProvider>().shops.firstWhere((s) => s.id == user.shopId);
      shopName = shop.name;
    } catch (_) {
      // Use placeholder or fetch if critical, but we have user.shopId
    }

    final productData = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      shopId: user.shopId!,
      shopName: shopName,
      vendorId: user.uid,
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      price: double.tryParse(_priceController.text) ?? 0.0,
      discountPrice: _discountPriceController.text.isNotEmpty ? double.tryParse(_discountPriceController.text) : null,
      sku: _skuController.text.trim(),
      stock: int.tryParse(_stockController.text) ?? 0,
      minStockAlert: int.tryParse(_minStockController.text) ?? 5,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await context.read<VendorProductProvider>().updateProduct(productData);
    } else {
      success = await context.read<VendorProductProvider>().addProduct(productData);
    }

    if (success && mounted) {
      SnackBarHelper.showSuccess(context, 'Product ${_isEditing ? 'updated' : 'added'} successfully');
      Navigator.pop(context);
    } else if (mounted) {
      SnackBarHelper.showError(context, context.read<VendorProductProvider>().errorMessage ?? 'Failed to save product');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorProductProvider>();
    final categories = context.watch<VendorCategoryProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: 'Basic Information',
                children: [
                  CustomTextField(
                    controller: _nameController,
                    label: 'Product Name',
                    hint: 'e.g. Fresh Organic Apples',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descController,
                    label: 'Description',
                    hint: 'Describe your product...',
                    maxLines: 4,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<CategoryModel>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ],
              ),
              _buildSectionCard(
                title: 'Pricing',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _priceController,
                          label: 'Price',
                          hint: '0.00',
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v!) == null || double.parse(v) <= 0 ? 'Invalid' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _discountPriceController,
                          label: 'Discount Price',
                          hint: 'Optional',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildSectionCard(
                title: 'Inventory',
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _skuController,
                          label: 'SKU',
                          hint: 'Unique ID',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: _generateSKU,
                        icon: const Icon(Icons.auto_awesome),
                        tooltip: 'Generate SKU',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _stockController,
                          label: 'Stock Quantity',
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v!) == null || int.parse(v) < 0 ? 'Invalid' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _minStockController,
                          label: 'Min Stock Alert',
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v!) == null ? 'Invalid' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: _isEditing ? 'Update Product' : 'Add Product',
                onPressed: _saveProduct,
                isLoading: provider.isLoading,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }
}
