import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../providers/admin_product_provider.dart';
import '../../providers/admin_order_provider.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../utils/date_formatter.dart';
import 'admin_drawer.dart';

class AllShopsScreen extends StatefulWidget {
  const AllShopsScreen({super.key});

  @override
  State<AllShopsScreen> createState() => _AllShopsScreenState();
}

class _AllShopsScreenState extends State<AllShopsScreen> {
  String _searchQuery = '';
  String? _selectedStatus;
  int _sortColumnIndex = 1;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().fetchShops();
      context.read<AdminProductProvider>().fetchAllProducts();
      context.read<AdminOrderProvider>().fetchAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Shops'),
      ),
      drawer: const AdminDrawer(),
      body: Consumer3<ShopProvider, AdminProductProvider, AdminOrderProvider>(
        builder: (context, shopProvider, productProvider, orderProvider, child) {
          if (shopProvider.isLoading || productProvider.isLoading || orderProvider.isLoading) {
            return const LoadingWidget();
          }

          if (shopProvider.error != null) {
            return AppErrorWidget(
              message: shopProvider.error!,
              onRetry: () => shopProvider.fetchShops(),
            );
          }

          List<ShopModel> filteredShops = shopProvider.shops.where((shop) {
            final matchesSearch = shop.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                shop.ownerId.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesStatus = _selectedStatus == null || shop.status == _selectedStatus;
            return matchesSearch && matchesStatus;
          }).toList();

          // Sorting
          filteredShops.sort((a, b) {
            dynamic aValue, bValue;
            switch (_sortColumnIndex) {
              case 1:
                aValue = a.name;
                bValue = b.name;
                break;
              case 2:
                aValue = a.ownerId;
                bValue = b.ownerId;
                break;
              case 3:
                aValue = a.status;
                bValue = b.status;
                break;
              case 6:
                aValue = a.createdAt;
                bValue = b.createdAt;
                break;
              default:
                aValue = a.name;
                bValue = b.name;
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
                if (filteredShops.isEmpty)
                  const EmptyStateWidget(
                    message: 'No shops found matching your criteria.',
                    icon: Icons.store_outlined,
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: PaginatedDataTable(
                      header: const Text('Shops List'),
                      columns: [
                        const DataColumn(label: Text('Icon')),
                        DataColumn(
                          label: const Text('Name'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _isAscending = ascending;
                            });
                          },
                        ),
                        DataColumn(
                          label: const Text('Vendor ID'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _isAscending = ascending;
                            });
                          },
                        ),
                        DataColumn(
                          label: const Text('Status'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _isAscending = ascending;
                            });
                          },
                        ),
                        const DataColumn(label: Text('Products')),
                        const DataColumn(label: Text('Orders')),
                        DataColumn(
                          label: const Text('Created Date'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _isAscending = ascending;
                            });
                          },
                        ),
                        const DataColumn(label: Text('Action')),
                      ],
                      source: _ShopDataSource(
                        shops: filteredShops,
                        productProvider: productProvider,
                        orderProvider: orderProvider,
                        onViewDetails: (shop) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(shop.name),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Vendor ID: ${shop.ownerId}'),
                                  const SizedBox(height: 8),
                                  Text('Status: ${shop.status.toUpperCase()}'),
                                  const SizedBox(height: 8),
                                  Text('Address: ${shop.address}'),
                                  const SizedBox(height: 8),
                                  Text('Created: ${DateFormatter.formatFullDate(shop.createdAt)}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      rowsPerPage: filteredShops.length > 10 ? 10 : filteredShops.isEmpty ? 1 : filteredShops.length,
                      showCheckboxColumn: false,
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

  Widget _buildFilters() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search by name or vendor...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        DropdownButton<String>(
          value: _selectedStatus,
          hint: const Text('Filter by Status'),
          items: [null, 'active', 'inactive', 'pending'].map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status?.toUpperCase() ?? 'ALL STATUS'),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedStatus = value),
        ),
      ],
    );
  }
}

class _ShopDataSource extends DataTableSource {
  final List<ShopModel> shops;
  final AdminProductProvider productProvider;
  final AdminOrderProvider orderProvider;
  final Function(ShopModel) onViewDetails;

  _ShopDataSource({
    required this.shops,
    required this.productProvider,
    required this.orderProvider,
    required this.onViewDetails,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= shops.length) return null;
    final shop = shops[index];

    final productCount = productProvider.products.where((p) => p.shopId == shop.id).length;
    final orderCount = orderProvider.orders.where((o) => o.shopName == shop.name).length;

    return DataRow(cells: [
      const DataCell(
        CircleAvatar(
          child: Icon(Icons.store),
        ),
      ),
      DataCell(Text(shop.name)),
      DataCell(Text(shop.ownerId)),
      DataCell(_buildStatusBadge(shop.status)),
      DataCell(Text(productCount.toString())),
      DataCell(Text(orderCount.toString())),
      DataCell(Text(DateFormatter.formatFullDate(shop.createdAt))),
      DataCell(
        TextButton(
          onPressed: () => onViewDetails(shop),
          child: const Text('View Details'),
        ),
      ),
    ]);
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => shops.length;

  @override
  int get selectedRowCount => 0;
}
