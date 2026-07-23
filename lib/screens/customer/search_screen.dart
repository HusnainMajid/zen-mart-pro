import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/admin_product_provider.dart';
import '../../providers/category_provider.dart';
import '../../core/routes/routes.dart';
import '../../utils/currency_formatter.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductProvider>().clearFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<AdminProductProvider>();
    
    final filteredProducts = productProvider.products.where((product) {
      final query = _searchQuery.toLowerCase();
      return product.name.toLowerCase().contains(query) ||
          product.categoryName.toLowerCase().contains(query) ||
          product.shopName.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialQuery == null,
          decoration: InputDecoration(
            hintText: 'Search products, categories, shops...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(128)),
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
      body: _searchQuery.isEmpty
          ? Consumer<CategoryProvider>(
              builder: (context, catProvider, _) {
                if (catProvider.isLoading) return const Center(child: CircularProgressIndicator());
                if (catProvider.categories.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Start typing to search...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Quick Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: catProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = catProvider.categories[index];
                          return ListTile(
                            leading: const Icon(Icons.category_outlined),
                            title: Text(category.name),
                            onTap: () {
                              setState(() {
                                _searchQuery = category.name;
                                _searchController.text = category.name;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            )
          : filteredProducts.isEmpty
              ? const Center(
                  child: Text('No results found.'),
                )
              : ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.inventory_2),
                      ),
                      title: Text(product.name),
                      subtitle: Text('${product.categoryName} • ${product.shopName}'),
                      trailing: Text(
                        CurrencyFormatter.format(product.discountPrice ?? product.price),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      onTap: () => context.push(Routes.productDetails, extra: product),
                    );
                  },
                ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
