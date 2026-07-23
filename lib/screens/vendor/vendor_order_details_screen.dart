import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../providers/vendor_order_provider.dart';
import '../../utils/snackbar_helper.dart';

class VendorOrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const VendorOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.orderNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(context),
            const SizedBox(height: 24),
            _buildCustomerInfo(context),
            const SizedBox(height: 24),
            _buildItemsList(context),
            const SizedBox(height: 24),
            _buildOrderSummary(context),
            if (order.orderNotes != null && order.orderNotes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildOrderNotes(context),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(context),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status).withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(order.status).withAlpha(51), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: _getStatusColor(order.status)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current Status', style: TextStyle(fontSize: 12)),
              Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(order.status),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            DateFormat('MMM dd, hh:mm a').format(order.orderTime),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow(Icons.person_outline, 'Customer Name', order.customerName),
                const Divider(height: 24),
                _buildInfoRow(Icons.location_on_outlined, 'Delivery Address', order.deliveryAddress),
                const Divider(height: 24),
                _buildInfoRow(Icons.payment_outlined, 'Payment Method', order.paymentMethod.toUpperCase()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('${order.items.length} items', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 12),
        ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: ListTile(
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('\$${item.price.toStringAsFixed(2)} x ${item.quantity}'),
                  trailing: Text(
                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final subtotal = order.total - order.tax + order.discount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', subtotal),
                const SizedBox(height: 8),
                _buildSummaryRow('Tax', order.tax),
                const SizedBox(height: 8),
                _buildSummaryRow('Discount', -order.discount, color: Colors.green),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Grand Total',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(
          '\$${value.abs().toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.w500, color: color),
        ),
      ],
    );
  }

  Widget _buildOrderNotes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Notes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withAlpha(51)),
          ),
          child: Text(
            order.orderNotes!,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget? _buildActionButtons(BuildContext context) {
    if (order.status == 'delivered' || order.status == 'cancelled') return null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (order.status == 'pending') ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _updateStatus(context, 'cancelled'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateStatus(context, 'accepted'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ] else if (order.status == 'accepted') ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateStatus(context, 'preparing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Start Preparing'),
                ),
              ),
            ] else if (order.status == 'preparing') ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateStatus(context, 'ready_for_pickup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Mark Ready for Pickup'),
                ),
              ),
            ] else if (order.status == 'ready_for_pickup') ...[
              const Expanded(
                child: Center(
                  child: Text(
                    'Waiting for Rider to Pickup',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    final provider = context.read<VendorOrderProvider>();
    final success = await provider.updateStatus(order.id, newStatus);
    
    if (context.mounted) {
      if (success) {
        SnackBarHelper.showSuccess(context, 'Order status updated to $newStatus');
        Navigator.pop(context);
      } else {
        SnackBarHelper.showError(context, provider.errorMessage ?? 'Failed to update status');
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
