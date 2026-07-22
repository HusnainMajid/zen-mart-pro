import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shop_provider.dart';
import '../../models/shop_model.dart';
import '../../services/storage_service.dart';
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
  final StorageService _storageService = StorageService();
  
  ShopModel? _shop;
  bool _isSaving = false;
  Map<String, String> _businessHours = {};
  
  File? _newLogo;
  File? _newBanner;

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
          _businessHours = Map<String, String>.from(shop.businessHours ?? {});
          if (_businessHours.isEmpty) {
            _businessHours = {
              'Monday': '09:00 - 18:00',
              'Tuesday': '09:00 - 18:00',
              'Wednesday': '09:00 - 18:00',
              'Thursday': '09:00 - 18:00',
              'Friday': '09:00 - 18:00',
              'Saturday': '10:00 - 16:00',
              'Sunday': 'Closed',
            };
          }
        });
      }
    }
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isLogo) {
          _newLogo = File(pickedFile.path);
        } else {
          _newBanner = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_shop == null) return;

    final shopProvider = context.read<ShopProvider>();
    final scaffoldContext = context;

    setState(() => _isSaving = true);

    try {
      String logoUrl = _shop!.logo;
      String bannerUrl = _shop!.banner;

      if (_newLogo != null) {
        logoUrl = await _storageService.uploadImage(
          _newLogo!,
          'shops/${_shop!.id}/logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      if (_newBanner != null) {
        bannerUrl = await _storageService.uploadImage(
          _newBanner!,
          'shops/${_shop!.id}/banner_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      final updatedShop = _shop!.copyWith(
        description: _descriptionController.text.trim(),
        contact: _contactController.text.trim(),
        logo: logoUrl,
        banner: bannerUrl,
        businessHours: _businessHours,
      );

      await shopProvider.updateShop(updatedShop);
      if (scaffoldContext.mounted) {
        SnackBarHelper.showSuccess(scaffoldContext, 'Shop profile updated successfully');
        setState(() {
          _shop = updatedShop;
          _newLogo = null;
          _newBanner = null;
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
              _buildBrandingSection(),
              const SizedBox(height: 24),
              _buildInfoSection(),
              const SizedBox(height: 24),
              _buildBusinessHoursSection(),
              const SizedBox(height: 24),
              _buildStatusSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Branding', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // Banner
        const Text('Shop Banner', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickImage(false),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              image: _newBanner != null
                  ? DecorationImage(image: FileImage(_newBanner!), fit: BoxFit.cover)
                  : _shop!.banner.isNotEmpty
                      ? DecorationImage(image: CachedNetworkImageProvider(_shop!.banner), fit: BoxFit.cover)
                      : null,
            ),
            child: const Center(child: Icon(Icons.camera_alt, color: Colors.white70, size: 40)),
          ),
        ),
        const SizedBox(height: 16),
        // Logo
        const Text('Shop Logo', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _newLogo != null
                    ? FileImage(_newLogo!)
                    : _shop!.logo.isNotEmpty
                        ? CachedNetworkImageProvider(_shop!.logo) as ImageProvider
                        : null,
                child: (_newLogo == null && _shop!.logo.isEmpty) ? const Icon(Icons.store, size: 50) : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                    onPressed: () => _pickImage(true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildBusinessHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Business Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._businessHours.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: entry.value,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _businessHours[entry.key] = value,
                  ),
                ),
              ],
            ),
          );
        }),
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
