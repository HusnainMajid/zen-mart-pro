import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../core/routes/routes.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/primary_button.dart';
import '../../utils/currency_formatter.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          IconButton(
            onPressed: () => _showClearCartDialog(context),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Cart',
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return const LoadingWidget();
          }

          if (cartProvider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: PrimaryButton(
                      text: 'Start Shopping',
                      onPressed: () => context.go(Routes.customerMain),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView( // Add scroll for small screens
                  child: ListView.builder(
                    shrinkWrap: true, // Needed when inside SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // Needed when inside SingleChildScrollView
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                child: Icon(Icons.inventory_2),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: Theme.of(context).textTheme.titleMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      CurrencyFormatter.format(item.price),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => cartProvider.updateQuantity(
                                        item.productId, item.quantity - 1),
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text(
                                    item.quantity.toString(),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  IconButton(
                                    onPressed: () => cartProvider.updateQuantity(
                                        item.productId, item.quantity + 1),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              _buildPriceBreakdown(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPriceBreakdown(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(76),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _priceRow(context, 'Subtotal', cartProvider.subtotal),
          _priceRow(context, 'Tax (5%)', cartProvider.tax),
          _priceRow(context, 'Discount', -cartProvider.discount, isDiscount: true),
          const Divider(),
          _priceRow(context, 'Total', cartProvider.total, isTotal: true),
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Proceed to Checkout',
            onPressed: () => context.push(Routes.checkout),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(BuildContext context, String label, double amount,
      {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: isTotal
                ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)
                : Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDiscount ? Colors.green : null,
                  ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Clear Cart',
        content: 'Are you sure you want to remove all items from your cart?',
        confirmText: 'Clear',
        onConfirm: () {
          Provider.of<CartProvider>(context, listen: false).clearCart();
        },
      ),
    );
  }
}
