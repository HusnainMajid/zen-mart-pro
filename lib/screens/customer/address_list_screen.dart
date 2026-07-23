import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          if (provider.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No addresses found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.addresses.length,
            itemBuilder: (context, index) {
              final address = provider.addresses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    children: [
                      Text(address.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text('Default', style: TextStyle(color: Colors.green, fontSize: 10)),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text('${address.street}, ${address.city}, ${address.state} ${address.zipCode}\n${address.country}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddressForm(context, address: address);
                      } else if (value == 'delete') {
                        _showDeleteConfirm(context, provider, address.id);
                      } else if (value == 'default') {
                        provider.setDefaultAddress(address.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      if (!address.isDefault)
                        const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add New Address'),
      ),
    );
  }

  void _showAddressForm(BuildContext context, {AddressModel? address}) {
    final titleController = TextEditingController(text: address?.title);
    final streetController = TextEditingController(text: address?.street);
    final cityController = TextEditingController(text: address?.city);
    final stateController = TextEditingController(text: address?.state);
    final zipController = TextEditingController(text: address?.zipCode);
    final countryController = TextEditingController(text: address?.country ?? 'Pakistan');
    bool isDefault = address?.isDefault ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  address == null ? 'Add New Address' : 'Edit Address',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title (e.g. Home, Office)')),
                TextField(controller: streetController, decoration: const InputDecoration(labelText: 'Street Address')),
                Row(
                  children: [
                    Expanded(child: TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: stateController, decoration: const InputDecoration(labelText: 'State'))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: TextField(controller: zipController, decoration: const InputDecoration(labelText: 'Zip Code'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: countryController, decoration: const InputDecoration(labelText: 'Country'))),
                  ],
                ),
                CheckboxListTile(
                  title: const Text('Set as default address'),
                  value: isDefault,
                  onChanged: (val) => setModalState(() => isDefault = val ?? false),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final provider = context.read<AddressProvider>();
                    final newAddress = AddressModel(
                      id: address?.id ?? '',
                      userId: '', // Service will populate this
                      title: titleController.text.trim(),
                      street: streetController.text.trim(),
                      city: cityController.text.trim(),
                      state: stateController.text.trim(),
                      zipCode: zipController.text.trim(),
                      country: countryController.text.trim(),
                      isDefault: isDefault,
                    );
                    
                    if (address == null) {
                      provider.addAddress(newAddress);
                    } else {
                      provider.updateAddress(newAddress);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(address == null ? 'Save Address' : 'Update Address'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AddressProvider provider, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.deleteAddress(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
