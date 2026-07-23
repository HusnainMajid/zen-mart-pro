import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/customer_order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/order_model.dart';
import '../../models/cart_item_model.dart';
import '../../core/routes/routes.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../utils/snackbar_helper.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: Consumer<CustomerOrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) return const LoadingWidget();
          if (orderProvider.orders.isEmpty) {
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
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
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
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
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
        color = Colors.blue;
        break;
      case 'shipped':
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
}
