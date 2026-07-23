import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../utils/date_formatter.dart';
import '../../utils/currency_formatter.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order: ${order.orderNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(context),
            const SizedBox(height: 24),
            _buildOrderInfo(context),
            const SizedBox(height: 24),
            _buildTimeline(context),
            const SizedBox(height: 24),
            _buildStakeholdersInfo(context),
            const SizedBox(height: 24),
            _buildPaymentSummary(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    Color color;
    switch (order.status.toLowerCase()) {
      case 'delivered': color = Colors.green; break;
      case 'pending': color = Colors.orange; break;
      case 'cancelled': color = Colors.red; break;
      case 'shipped': color = Colors.blue; break;
      default: color = Colors.grey;
    }

    return Card(
      color: color.withAlpha(25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: color),
            const SizedBox(width: 12),
            Text(
              'Status: ${order.status.toUpperCase()}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Spacer(),
            Text(
              DateFormatter.formatDateTime(order.orderTime),
              style: TextStyle(color: color.withAlpha(204)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Summary', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _buildInfoTile('Order Number', order.orderNumber),
        _buildInfoTile('Shop Name', order.shopName),
        _buildInfoTile('Total Amount', CurrencyFormatter.format(order.total)),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Timeline', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildTimelineItem('Order Placed', order.orderTime, isCompleted: true),
        _buildTimelineItem(
          'Delivered', 
          order.deliveryTime, 
          isCompleted: order.status.toLowerCase() == 'delivered',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String title, DateTime? time, {bool isCompleted = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (time != null)
                Text(DateFormatter.formatDateTime(time), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStakeholdersInfo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSectionCard(
            context,
            'Customer',
            order.customerName,
            Icons.person_outline,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSectionCard(
            context,
            'Rider',
            order.riderName ?? 'Not Assigned',
            Icons.delivery_dining_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, String name, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(76),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Method'),
              Text(order.paymentMethod.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                CurrencyFormatter.format(order.total),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
