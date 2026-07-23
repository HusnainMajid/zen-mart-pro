import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/customer_order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/order_model.dart';
import '../../models/cart_item_model.dart';
import '../../core/routes/routes.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../utils/snackbar_helper.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _searchQuery = '';
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                SearchBar(
                  hintText: 'Search by order number...',
                  leading: const Icon(Icons.search),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(Colors.white.withAlpha(50)),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(label: 'All', isSelected: _statusFilter == null, onSelected: () => setState(() => _statusFilter = null)),
                      _FilterChip(label: 'Pending', isSelected: _statusFilter == 'pending', onSelected: () => setState(() => _statusFilter = 'pending')),
                      _FilterChip(label: 'Delivered', isSelected: _statusFilter == 'delivered', onSelected: () => setState(() => _statusFilter = 'delivered')),
                      _FilterChip(label: 'Cancelled', isSelected: _statusFilter == 'cancelled', onSelected: () => setState(() => _statusFilter = 'cancelled')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<CustomerOrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) return const LoadingWidget();

          final filteredOrders = orderProvider.orders.where((order) {
            final matchesQuery = order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesStatus = _statusFilter == null || order.status.toLowerCase() == _statusFilter;
            return matchesQuery && matchesStatus;
          }).toList();

          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No orders found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    orderProvider.startTracking(order.id);
                    context.push(Routes.orderTracking, extra: order);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.orderNumber,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  DateFormatter.formatDateTime(order.orderTime),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            _buildStatusBadge(context, order.status),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.store_outlined, size: 16),
                            const SizedBox(width: 8),
                            Text(order.shopName, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${order.items.length} items • Total: ${CurrencyFormatter.format(order.total)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _reorder(context, order),
                              icon: const Icon(Icons.reorder, size: 18),
                              label: const Text('Reorder'),
                              style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                            ),
                            const SizedBox(width: 8),
                            if (order.status.toLowerCase() == 'pending')
                              TextButton(
                                onPressed: () => _confirmCancel(context, order),
                                child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                              ),
                            const Spacer(),
                            Text(
                              'Track Order',
                              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
      case 'processing':
      case 'preparing':
        color = Colors.blue;
        break;
      case 'shipped':
      case 'picked_up':
      case 'ready_for_pickup':
      case 'out_for_delivery':
        color = Colors.purple;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _reorder(BuildContext context, OrderModel order) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    for (var item in order.items) {
      cartProvider.addToCart(CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() + item.productId,
        productId: item.productId,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        total: item.total,
        shopId: order.shopId,
      ));
    }
    SnackBarHelper.showSuccess(context, 'Items added to cart');
  }

  void _confirmCancel(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Cancel Order',
        content: 'Are you sure you want to cancel order ${order.orderNumber}?',
        confirmText: 'Cancel Order',
        onConfirm: () async {
          try {
            await context.read<CustomerOrderProvider>().cancelOrder(order.id);
            if (context.mounted) SnackBarHelper.showSuccess(context, 'Order cancelled');
          } catch (e) {
            if (context.mounted) SnackBarHelper.showError(context, 'Failed to cancel order: $e');
          }
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
