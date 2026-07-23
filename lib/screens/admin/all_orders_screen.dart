import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/order_model.dart';
import '../../providers/admin_order_provider.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../utils/date_formatter.dart';
import '../../utils/currency_formatter.dart';
import '../../core/routes/routes.dart';
import 'admin_drawer.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  String _searchQuery = '';
  String? _selectedStatus;
  DateTimeRange? _selectedDateRange;
  int _sortColumnIndex = 6;
  bool _isAscending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrderProvider>().listenToAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders'),
      ),
      drawer: const AdminDrawer(),
      body: Consumer<AdminOrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.errorMessage != null) {
            return AppErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.fetchAllOrders(),
            );
          }

          List<OrderModel> filteredOrders = provider.orders.where((order) {
            final matchesSearch = order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                order.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesStatus = _selectedStatus == null || order.status == _selectedStatus;
            
            bool matchesDate = true;
            if (_selectedDateRange != null) {
              matchesDate = order.orderTime.isAfter(_selectedDateRange!.start) &&
                  order.orderTime.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
            }

            return matchesSearch && matchesStatus && matchesDate;
          }).toList();

          // Sorting
          filteredOrders.sort((a, b) {
            dynamic aValue, bValue;
            switch (_sortColumnIndex) {
              case 0: aValue = a.orderNumber; bValue = b.orderNumber; break;
              case 1: aValue = a.customerName; bValue = b.customerName; break;
              case 5: aValue = a.total; bValue = b.total; break;
              case 6: aValue = a.status; bValue = b.status; break;
              case 7: aValue = a.orderTime; bValue = b.orderTime; break;
              default: aValue = a.orderTime; bValue = b.orderTime;
            }
            return _isAscending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilters(),
                const SizedBox(height: 16),
                if (filteredOrders.isEmpty)
                  const EmptyStateWidget(
                    message: 'No orders found.',
                    icon: Icons.receipt_long_outlined,
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: PaginatedDataTable(
                      header: const Text('Orders List'),
                      columns: [
                        DataColumn(label: const Text('Order #'), onSort: _onSort),
                        DataColumn(label: const Text('Customer'), onSort: _onSort),
                        const DataColumn(label: Text('Vendor')),
                        const DataColumn(label: Text('Rider')),
                        const DataColumn(label: Text('Payment')),
                        DataColumn(label: const Text('Total'), onSort: _onSort, numeric: true),
                        DataColumn(label: const Text('Status'), onSort: _onSort),
                        DataColumn(label: const Text('Order Time'), onSort: _onSort),
                        const DataColumn(label: Text('Action')),
                      ],
                      source: _OrderDataSource(
                        orders: filteredOrders,
                        onViewDetails: (order) => context.push(Routes.orderDetails, extra: order),
                      ),
                      rowsPerPage: filteredOrders.length > 10 ? 10 : (filteredOrders.isEmpty ? 1 : filteredOrders.length),
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _isAscending,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
    });
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search order # or customer...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        DropdownButton<String>(
          value: _selectedStatus,
          hint: const Text('Status'),
          items: [null, 'pending', 'accepted', 'preparing', 'ready_for_pickup', 'picked_up', 'out_for_delivery', 'delivered', 'cancelled'].map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status?.toUpperCase().replaceAll('_', ' ') ?? 'All Status'),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedStatus = value),
        ),
        TextButton.icon(
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2023),
              lastDate: DateTime.now(),
              initialDateRange: _selectedDateRange,
            );
            if (picked != null) setState(() => _selectedDateRange = picked);
          },
          icon: const Icon(Icons.date_range),
          label: Text(_selectedDateRange == null
              ? 'Select Date Range'
              : '${DateFormatter.formatFullDate(_selectedDateRange!.start)} - ${DateFormatter.formatFullDate(_selectedDateRange!.end)}'),
        ),
        if (_selectedDateRange != null)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => setState(() => _selectedDateRange = null),
          ),
      ],
    );
  }
}

class _OrderDataSource extends DataTableSource {
  final List<OrderModel> orders;
  final Function(OrderModel) onViewDetails;

  _OrderDataSource({required this.orders, required this.onViewDetails});

  @override
  DataRow? getRow(int index) {
    if (index >= orders.length) return null;
    final order = orders[index];

    return DataRow(cells: [
      DataCell(Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(order.customerName)),
      DataCell(Text(order.shopName)),
      DataCell(Text(order.riderName ?? 'Not Assigned')),
      DataCell(Text(order.paymentMethod.toUpperCase())),
      DataCell(Text(CurrencyFormatter.format(order.total))),
      DataCell(_buildStatusBadge(order.status)),
      DataCell(Text(DateFormatter.formatDateTime(order.orderTime))),
      DataCell(
        TextButton(
          onPressed: () => onViewDetails(order),
          child: const Text('View Details'),
        ),
      ),
    ]);
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered': color = Colors.green; break;
      case 'pending': color = Colors.orange; break;
      case 'cancelled': color = Colors.red; break;
      case 'accepted': color = Colors.blue; break;
      case 'preparing': color = Colors.purple; break;
      case 'ready_for_pickup': color = Colors.indigo; break;
      case 'picked_up': color = Colors.cyan; break;
      case 'out_for_delivery': color = Colors.teal; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => orders.length;
  @override
  int get selectedRowCount => 0;
}
