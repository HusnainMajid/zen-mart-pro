import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shop_provider.dart';
import '../../models/shop_model.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../utils/snackbar_helper.dart';
import 'package:intl/intl.dart';

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  
  ShopModel? _shop;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadShopData());
  }

  Future<void> _loadShopData() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null && user.shopId != null) {
      final shop = await context.read<ShopProvider>().getShopById(user.shopId!);
      if (mounted && shop != null) {
        setState(() {
          _shop = shop;
          _descriptionController.text = shop.description;
          _contactController.text = shop.contact;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_shop == null) return;

    final shopProvider = context.read<ShopProvider>();
    final scaffoldContext = context;

    setState(() => _isSaving = true);

    try {
      final updatedShop = _shop!.copyWith(
        description: _descriptionController.text.trim(),
        contact: _contactController.text.trim(),
      );

      await shopProvider.updateShop(updatedShop);
      if (scaffoldContext.mounted) {
        SnackBarHelper.showSuccess(scaffoldContext, 'Shop profile updated successfully');
        setState(() {
          _shop = updatedShop;
        });
      }
    } catch (e) {
      if (scaffoldContext.mounted) SnackBarHelper.showError(scaffoldContext, e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_shop == null) return const Scaffold(body: LoadingWidget());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Profile'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection(),
              const SizedBox(height: 24),
              _buildStatusSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('General Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Shop Description',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _contactController,
          decoration: const InputDecoration(
            labelText: 'Contact Number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) => value == null || value.isEmpty ? 'Contact number is required' : null,
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status & Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Shop Status'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _shop!.status == 'active' ? Colors.green.withAlpha(26) : Colors.orange.withAlpha(26),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _shop!.status.toUpperCase(),
              style: TextStyle(
                color: _shop!.status == 'active' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Created Date'),
          trailing: Text(DateFormat('MMM dd, yyyy').format(_shop!.createdAt)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}
