import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_order_provider.dart';
import '../../models/order_model.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel? order; // Initial order data

  const OrderTrackingScreen({super.key, this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CustomerOrderProvider>().startTracking(widget.order!.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: Consumer<CustomerOrderProvider>(
        builder: (context, orderProvider, child) {
          final order = orderProvider.currentTrackingOrder ?? widget.order;
          
          if (order == null) {
            return const Center(child: Text('No order selected for tracking.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(76),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Delivery',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.deliveryTime != null 
                              ? DateFormatter.formatDateTime(order.deliveryTime!)
                              : 'Pending Confirmation',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Order Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildVerticalTimeline(context, order.status),
                const SizedBox(height: 32),
                Text(
                  'Order Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildItemsList(order),
                const Divider(height: 32),
                _buildTotalSection(order),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              order.orderNumber,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Placed on ${DateFormatter.formatDateTime(order.orderTime)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildVerticalTimeline(BuildContext context, String currentStatus) {
    final steps = [
      {'status': 'pending', 'title': 'Order Placed', 'subtitle': 'Your order has been received'},
      {'status': 'confirmed', 'title': 'Accepted', 'subtitle': 'Vendor has accepted your order'},
      {'status': 'preparing', 'title': 'Preparing', 'subtitle': 'Your items are being prepared'},
      {'status': 'ready_for_pickup', 'title': 'Ready for Pickup', 'subtitle': 'Your order is ready to be collected'},
      {'status': 'picked_up', 'title': 'Picked Up', 'subtitle': 'Rider has picked up your order'},
      {'status': 'out_for_delivery', 'title': 'Out for Delivery', 'subtitle': 'Rider is heading to your location'},
      {'status': 'delivered', 'title': 'Delivered', 'subtitle': 'Enjoy your purchase!'},
    ];

    // Find current index
    int currentIdx = steps.indexWhere((s) => s['status'] == currentStatus.toLowerCase());
    
    // Fallback for status names that might vary slightly or legacy names
    if (currentIdx == -1) {
      if (currentStatus.toLowerCase() == 'accepted') currentIdx = 1;
      if (currentStatus.toLowerCase() == 'processing') currentIdx = 2;
      if (currentStatus.toLowerCase() == 'shipped') currentIdx = 5;
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final bool isDone = index <= currentIdx;
        final bool isCurrent = index == currentIdx;
        final bool isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDone ? Colors.green : Colors.grey[300],
                      shape: BoxShape.circle,
                      border: isCurrent ? Border.all(color: Colors.green, width: 4) : null,
                    ),
                    child: isDone && !isCurrent
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: index < currentIdx ? Colors.green : Colors.grey[300],
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[index]['title']!,
                        style: TextStyle(
                          fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                          color: isDone ? Colors.black : Colors.grey,
                        ),
                      ),
                      Text(
                        steps[index]['subtitle']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDone ? Colors.black54 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildItemsList(OrderModel order) {
    return Column(
      children: order.items.map<Widget>((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${item.quantity}x ${item.name}'),
              Text(CurrencyFormatter.format(item.total)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTotalSection(OrderModel order) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal'),
            Text(CurrencyFormatter.format(order.total - order.tax)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tax'),
            Text(CurrencyFormatter.format(order.tax)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              CurrencyFormatter.format(order.total),
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
}
