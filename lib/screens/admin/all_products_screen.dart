import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/admin_product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/shop_provider.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../utils/date_formatter.dart';
import '../../utils/currency_formatter.dart';
import 'admin_drawer.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedShop;
  int _sortColumnIndex = 1;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductProvider>().fetchAllProducts();
      context.read<CategoryProvider>().fetchCategories();
      context.read<ShopProvider>().fetchShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
      ),
      drawer: const AdminDrawer(),
      body: Consumer3<AdminProductProvider, CategoryProvider, ShopProvider>(
        builder: (context, productProvider, categoryProvider, shopProvider, child) {
          if (productProvider.isLoading) {
            return const LoadingWidget();
          }

          if (productProvider.errorMessage != null) {
            return AppErrorWidget(
              message: productProvider.errorMessage!,
              onRetry: () => productProvider.fetchAllProducts(),
            );
          }

          List<ProductModel> filteredProducts = productProvider.products.where((product) {
            final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesCategory = _selectedCategory == null || product.categoryId == _selectedCategory;
            final matchesShop = _selectedShop == null || product.shopId == _selectedShop;
            return matchesSearch && matchesCategory && matchesShop;
          }).toList();

          // Sorting
          filteredProducts.sort((a, b) {
            dynamic aValue, bValue;
            switch (_sortColumnIndex) {
              case 1: aValue = a.name; bValue = b.name; break;
              case 2: aValue = a.shopName; bValue = b.shopName; break;
              case 4: aValue = a.categoryName; bValue = b.categoryName; break;
              case 5: aValue = a.price; bValue = b.price; break;
              case 6: aValue = a.stock; bValue = b.stock; break;
              case 7: aValue = a.createdAt; bValue = b.createdAt; break;
              default: aValue = a.name; bValue = b.name;
            }
            return _isAscending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilters(categoryProvider, shopProvider),
                const SizedBox(height: 16),
                if (filteredProducts.isEmpty)
                  const EmptyStateWidget(
                    message: 'No products found.',
                    icon: Icons.inventory_2_outlined,
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: PaginatedDataTable(
                      header: const Text('Products List'),
                      columns: [
                        const DataColumn(label: Text('Icon')),
                        DataColumn(label: const Text('Name'), onSort: _onSort),
                        DataColumn(label: const Text('Shop'), onSort: _onSort),
                        const DataColumn(label: Text('Vendor ID')),
                        DataColumn(label: const Text('Category'), onSort: _onSort),
                        DataColumn(label: const Text('Price'), onSort: _onSort, numeric: true),
                        DataColumn(label: const Text('Stock'), onSort: _onSort, numeric: true),
                        DataColumn(label: const Text('Created Date'), onSort: _onSort),
                      ],
                      source: _ProductDataSource(products: filteredProducts),
                      rowsPerPage: filteredProducts.length > 10 ? 10 : (filteredProducts.isEmpty ? 1 : filteredProducts.length),
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

  Widget _buildFilters(CategoryProvider catProvider, ShopProvider shopProvider) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        DropdownButton<String>(
          value: _selectedCategory,
          hint: const Text('Category'),
          items: [null, ...catProvider.categories].map((cat) {
            return DropdownMenuItem<String>(
              value: cat?.id,
              child: Text(cat?.name ?? 'All Categories'),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value),
        ),
        DropdownButton<String>(
          value: _selectedShop,
          hint: const Text('Shop'),
          items: [null, ...shopProvider.shops].map((shop) {
            return DropdownMenuItem<String>(
              value: shop?.id,
              child: Text(shop?.name ?? 'All Shops'),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedShop = value),
        ),
      ],
    );
  }
}

class _ProductDataSource extends DataTableSource {
  final List<ProductModel> products;

  _ProductDataSource({required this.products});

  @override
  DataRow? getRow(int index) {
    if (index >= products.length) return null;
    final product = products[index];

    return DataRow(cells: [
      const DataCell(
        Icon(Icons.inventory_2, size: 24, color: Colors.grey),
      ),
      DataCell(Text(product.name)),
      DataCell(Text(product.shopName)),
      DataCell(Text(product.vendorId)),
      DataCell(Text(product.categoryName)),
      DataCell(Text(CurrencyFormatter.format(product.price))),
      DataCell(Text(product.stock.toString())),
      DataCell(Text(DateFormatter.formatFullDate(product.createdAt))),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => products.length;
  @override
  int get selectedRowCount => 0;
}
