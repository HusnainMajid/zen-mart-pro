import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/shop_banner_model.dart';
import '../../providers/shop_banner_provider.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../utils/snackbar_helper.dart';

class ShopBannerScreen extends StatefulWidget {
  const ShopBannerScreen({super.key});

  @override
  State<ShopBannerScreen> createState() => _ShopBannerScreenState();
}

class _ShopBannerScreenState extends State<ShopBannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopBannerProvider>().fetchBanners();
    });
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => const UploadBannerDialog(),
    );
  }

  void _confirmDelete(ShopBannerModel banner) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Banner',
        content: 'Are you sure you want to delete this banner?',
        confirmText: 'Delete',
        onConfirm: () async {
          final success = await context.read<ShopBannerProvider>().deleteBanner(banner);
          if (!context.mounted) return;
          if (success) {
            SnackBarHelper.showSuccess(context, 'Banner deleted successfully');
          } else {
            SnackBarHelper.showError(context, context.read<ShopBannerProvider>().errorMessage ?? 'Failed to delete banner');
          }
        },
      ),
    );
  }

  void _showBannerPreview(ShopBannerModel banner) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: banner.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const SizedBox(
                    height: 200,
                    child: LoadingWidget(),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                banner.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Banners'),
      ),
      body: Consumer<ShopBannerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.banners.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.errorMessage != null && provider.banners.isEmpty) {
            return AppErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.fetchBanners(),
            );
          }

          if (provider.banners.isEmpty) {
            return const EmptyStateWidget(
              message: 'No banners uploaded yet',
              icon: Icons.image_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchBanners,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: provider.banners.length,
              itemBuilder: (context, index) {
                final banner = provider.banners[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _showBannerPreview(banner),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: banner.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black87, Colors.transparent],
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    banner.title,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                                  onPressed: () => _confirmDelete(banner),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        label: const Text('Upload Banner'),
        icon: const Icon(Icons.upload),
      ),
    );
  }
}

class UploadBannerDialog extends StatefulWidget {
  const UploadBannerDialog({super.key});

  @override
  State<UploadBannerDialog> createState() => _UploadBannerDialogState();
}

class _UploadBannerDialogState extends State<UploadBannerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      SnackBarHelper.showError(context, 'Please select a banner image');
      return;
    }

    setState(() => _isUploading = true);
    final provider = context.read<ShopBannerProvider>();
    final success = await provider.uploadBanner(
      title: _titleController.text.trim(),
      imageFile: _selectedImage!,
    );

    if (!mounted) return;
    setState(() => _isUploading = false);
    if (!context.mounted) return;
    if (success) {
      SnackBarHelper.showSuccess(context, 'Banner uploaded successfully');
      Navigator.of(context).pop();
    } else {
      SnackBarHelper.showError(context, provider.errorMessage ?? 'An error occurred');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Shop Banner'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Select Banner Image', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _titleController,
                label: 'Banner Title',
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        SizedBox(
          width: 100,
          child: PrimaryButton(
            text: 'Upload',
            onPressed: _upload,
            isLoading: _isUploading,
          ),
        ),
      ],
    );
  }
}
