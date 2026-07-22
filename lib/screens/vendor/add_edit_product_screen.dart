import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  final _minStockController = TextEditingController();
  final _weightController = TextEditingController();
  final _unitController = TextEditingController();

  // Selection states
  CategoryModel? _selectedCategory;
  String _status = 'available';
  bool _isFeatured = false;
  bool _isAvailable = true;

  // Media states
  final List<File> _newImages = [];
  final List<String> _existingImages = [];
  final List<String> _removedImages = [];

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
      _weightController.text = p.weight?.toString() ?? '';
      _unitController.text = p.unit ?? '';
      _status = p.status;
      _isFeatured = p.isFeatured;
      _isAvailable = p.isAvailable;
      _existingImages.addAll(p.images);
      
      // Load categories to match the selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final categories = context.read<VendorCategoryProvider>().categories;
        if (categories.isNotEmpty) {
          setState(() {
            _selectedCategory = categories.firstWhere(
              (c) => c.id == p.categoryId,
              orElse: () => categories.first,
            );
          });
        }
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedFiles.map((f) => File(f.path)));
      });
    }
  }
  
  // Actually let's fix the typo in the code before writing
  // _newImages.addAll(pickedFiles.map((f) => File(f.path)));

  void _generateSKU() {
    if (_selectedCategory == null) {
      SnackBarHelper.showInfo(context, 'Please select a category first');
      return;
    }
    final shop = context.read<ShopProvider>().shops.firstWhere(
      (s) => s.ownerId == context.read<AuthProvider>().currentUser?.uid,
      orElse: () => context.read<ShopProvider>().shops.first,
    );
    final sku = context.read<VendorProductProvider>().generateSKU(_selectedCategory!.name, shop.name);
    setState(() => _skuController.text = sku);
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      SnackBarHelper.showError(context, 'Please select a category');
      return;
    }
    if (_newImages.isEmpty && _existingImages.isEmpty) {
      SnackBarHelper.showError(context, 'At least one product image is required');
      return;
    }

    final user = context.read<AuthProvider>().currentUser!;
    final shop = context.read<ShopProvider>().shops.firstWhere((s) => s.ownerId == user.uid);

    final productData = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      shopId: shop.id,
      shopName: shop.name,
      vendorId: user.uid,
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      price: double.parse(_priceController.text),
      discountPrice: _discountPriceController.text.isNotEmpty ? double.parse(_discountPriceController.text) : null,
      sku: _skuController.text.trim(),
      stock: int.parse(_stockController.text),
      minStockAlert: int.parse(_minStockController.text),
      weight: _weightController.text.isNotEmpty ? double.parse(_weightController.text) : null,
      unit: _unitController.text.trim(),
      status: _status,
      isFeatured: _isFeatured,
      isAvailable: _isAvailable,
      imageUrl: _existingImages.isNotEmpty ? _existingImages[0] : '', // Will be updated by provider if new images
      images: _existingImages,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await context.read<VendorProductProvider>().updateProduct(
        productData,
        newImages: _newImages,
        removedImages: _removedImages,
      );
    } else {
      success = await context.read<VendorProductProvider>().addProduct(productData, _newImages);
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _weightController,
                          label: 'Weight',
                          hint: '0.0',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _unitController,
                          label: 'Unit',
                          hint: 'kg, pcs, etc.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildSectionCard(
                title: 'Media',
                children: [
                  const Text('Product Images', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _buildImageGrid(),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add Images'),
                  ),
                ],
              ),
              _buildSectionCard(
                title: 'Settings',
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'available', child: Text('Available')),
                      DropdownMenuItem(value: 'hidden', child: Text('Hidden')),
                      DropdownMenuItem(value: 'out_of_stock', child: Text('Out of Stock')),
                    ],
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Featured Product'),
                    subtitle: const Text('Display this product in featured section'),
                    value: _isFeatured,
                    onChanged: (val) => setState(() => _isFeatured = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Available for Sale'),
                    value: _isAvailable,
                    onChanged: (val) => setState(() => _isAvailable = val),
                    contentPadding: EdgeInsets.zero,
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

  Widget _buildImageGrid() {
    final allImagesCount = _existingImages.length + _newImages.length;
    if (allImagesCount == 0) {
      return Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Icon(Icons.image_outlined, size: 40, color: Colors.grey)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: allImagesCount,
      itemBuilder: (context, index) {
        if (index < _existingImages.length) {
          final url = _existingImages[index];
          return _ImageThumbnail(
            image: CachedNetworkImageProvider(url),
            onRemove: () {
              setState(() {
                _removedImages.add(url);
                _existingImages.removeAt(index);
              });
            },
          );
        } else {
          final fileIndex = index - _existingImages.length;
          final file = _newImages[fileIndex];
          return _ImageThumbnail(
            image: FileImage(file),
            onRemove: () {
              setState(() => _newImages.removeAt(fileIndex));
            },
          );
        }
      },
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
    _weightController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}

class _ImageThumbnail extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback onRemove;

  const _ImageThumbnail({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(image: image, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
