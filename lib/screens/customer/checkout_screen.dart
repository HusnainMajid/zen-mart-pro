import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/customer_order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../models/order_item_model.dart';
import '../../core/routes/routes.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/primary_button.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/snackbar_helper.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  final String _selectedPaymentMethod = 'Cash on Delivery';
  String? _selectedAddressId;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);
    final orderProvider = Provider.of<CustomerOrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (cartProvider.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Your cart is empty'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(Routes.customerMain),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            if (_currentStep == 0) {
              final address = _selectedAddressId != null
                  ? addressProvider.addresses.firstWhere((a) => a.id == _selectedAddressId)
                  : addressProvider.defaultAddress;
              if (address == null) {
                SnackBarHelper.showError(context, 'Please select a delivery address');
                return;
              }
              _selectedAddressId = address.id;
            }
            setState(() => _currentStep += 1);
          } else {
            _placeOrder(context, cartProvider, addressProvider, orderProvider, authProvider);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            context.pop();
          }
        },
        controlsBuilder: (context, controls) {
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: _currentStep == 2 ? 'Place Order' : 'Continue',
                    onPressed: controls.onStepContinue!,
                    isLoading: orderProvider.isLoading,
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: controls.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Address'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildAddressSelection(addressProvider),
          ),
          Step(
            title: const Text('Payment'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildPaymentMethod(),
          ),
          Step(
            title: const Text('Summary'),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: _buildOrderSummary(cartProvider, addressProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSelection(AddressProvider addressProvider) {
    if (addressProvider.isLoading) return const LoadingWidget();
    if (addressProvider.addresses.isEmpty) {
      return Column(
        children: [
          const Text('No saved addresses found.'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.push(Routes.addresses),
            child: const Text('Add New Address'),
          ),
        ],
      );
    }

    return Column(
      children: [
        ...addressProvider.addresses.map((address) {
          // ignore: deprecated_member_use
          return RadioListTile<String>(
            title: Text(address.title),
            subtitle: Text('${address.street}, ${address.city}'),
            value: address.id,
            // ignore: deprecated_member_use
            groupValue: _selectedAddressId ?? addressProvider.defaultAddress?.id,
            // ignore: deprecated_member_use
            onChanged: (value) {
              setState(() => _selectedAddressId = value);
            },
          );
        }),
        const Divider(),
        TextButton.icon(
          onPressed: () => context.push(Routes.addresses),
          icon: const Icon(Icons.add),
          label: const Text('Manage Addresses'),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      children: [
        // ignore: deprecated_member_use
        RadioListTile<String>(
          title: const Text('Cash on Delivery'),
          subtitle: const Text('Pay when you receive your order'),
          value: 'Cash on Delivery',
          // ignore: deprecated_member_use
          groupValue: _selectedPaymentMethod,
          // ignore: deprecated_member_use
          onChanged: null, // Only COD supported for now
        ),
      ],
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider, AddressProvider addressProvider) {
    final address = addressProvider.addresses.firstWhere(
      (a) => a.id == (_selectedAddressId ?? addressProvider.defaultAddress?.id),
      orElse: () => addressProvider.addresses.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery to ${address.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${address.street}, ${address.city}, ${address.state}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Items Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...cartProvider.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('${item.quantity}x ${item.name}', maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text(CurrencyFormatter.format(item.total)),
                ],
              ),
            )),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal'),
            Text(CurrencyFormatter.format(cartProvider.subtotal)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tax (5%)'),
            Text(CurrencyFormatter.format(cartProvider.tax)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              CurrencyFormatter.format(cartProvider.total),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _placeOrder(
    BuildContext context,
    CartProvider cartProvider,
    AddressProvider addressProvider,
    CustomerOrderProvider orderProvider,
    AuthProvider authProvider,
  ) async {
    final user = authProvider.currentUser;
    if (user == null) return;

    final address = addressProvider.addresses.firstWhere(
      (a) => a.id == (_selectedAddressId ?? addressProvider.defaultAddress?.id),
    );

    try {
      // Group items by shopId as OrderModel is per shop
      final Map<String, List<OrderItemModel>> itemsByShop = {};
      final Map<String, String> shopNames = {};

      for (var item in cartProvider.items) {
        if (!itemsByShop.containsKey(item.shopId)) {
          itemsByShop[item.shopId] = [];
          shopNames[item.shopId] = 'Shop ${item.shopId.substring(0, 5)}'; // Placeholder shop name
        }
        itemsByShop[item.shopId]!.add(OrderItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + item.productId,
          productId: item.productId,
          name: item.name,
          price: item.price,
          quantity: item.quantity,
          total: item.total,
        ));
      }

      for (var entry in itemsByShop.entries) {
        final shopId = entry.key;
        final items = entry.value;
        final shopSubtotal = items.fold(0.0, (sum, item) => sum + item.total);
        final shopTax = shopSubtotal * 0.05;

        final order = OrderModel(
          id: '', 
          orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
          customerId: user.uid,
          customerName: user.fullName,
          vendorId: 'vendor_$shopId', // Placeholder vendorId
          shopId: shopId,
          shopName: shopNames[shopId]!,
          paymentMethod: _selectedPaymentMethod,
          total: shopSubtotal + shopTax,
          tax: shopTax,
          discount: 0,
          status: 'pending',
          orderTime: DateTime.now(),
          items: items,
          deliveryAddress: '${address.street}, ${address.city}, ${address.state}',
        );

        await orderProvider.placeOrder(order);
      }

      await cartProvider.clearCart();
      if (!context.mounted) return;
      
      SnackBarHelper.showSuccess(context, 'Order placed successfully!');
      context.go(Routes.customerMain);
    } catch (e) {
      if (!context.mounted) return;
      SnackBarHelper.showError(context, 'Failed to place order: $e');
    }
  }
}
