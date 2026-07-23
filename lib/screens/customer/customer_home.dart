import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:go_router/go_router.dart';
import '../../providers/category_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/admin_product_provider.dart';
import '../../core/routes/routes.dart';
import '../../models/product_model.dart';
import '../../models/shop_model.dart';
import '../../models/category_model.dart';
import '../../utils/currency_formatter.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      context.read<ShopProvider>().fetchShops();
      context.read<AdminProductProvider>().fetchAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              context.read<CategoryProvider>().fetchCategories(),
              context.read<ShopProvider>().fetchShops(),
              context.read<AdminProductProvider>().fetchAllProducts(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              // Search Bar at Top
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SearchBar(
                    hintText: 'Search products, shops...',
                    leading: const Icon(Icons.search),
                    onTap: () {
                      // Navigate to search screen or handle search
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Categories
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Categories',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<CategoryProvider>(
                      builder: (context, categoryProvider, _) {
                        return Skeletonizer(
                          enabled: categoryProvider.isLoading,
                          child: SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: categoryProvider.isLoading ? 6 : categoryProvider.categories.length,
                              itemBuilder: (context, index) {
                                final category = categoryProvider.isLoading ? null : categoryProvider.categories[index];
                                return _buildCategoryItem(category);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Featured Shops
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured Shops',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to all shops
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<ShopProvider>(
                      builder: (context, shopProvider, _) {
                        return Skeletonizer(
                          enabled: shopProvider.isLoading,
                          child: SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: shopProvider.isLoading ? 4 : shopProvider.shops.length,
                              itemBuilder: (context, index) {
                                final shop = shopProvider.isLoading ? null : shopProvider.shops[index];
                                return _buildShopCard(context, shop);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Popular Products
              _buildProductSection(
                title: 'Popular Products',
                filter: (products) => products.take(10).toList(),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel? category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.withAlpha(25),
            child: const Icon(Icons.category, color: Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            category?.name ?? 'Category',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, ShopModel? shop) {
    return GestureDetector(
      onTap: () {
        if (shop != null) {
          context.push(Routes.shopDetails, extra: shop);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.store, size: 48, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop?.name ?? 'Shop Name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 4),
                        Text('4.5', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSection({
    required String title,
    required List<ProductModel> Function(List<ProductModel>) filter,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Consumer<AdminProductProvider>(
            builder: (context, productProvider, _) {
              final products = filter(productProvider.products);
              return Skeletonizer(
                enabled: productProvider.isLoading,
                child: SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: productProvider.isLoading ? 4 : products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.isLoading ? null : products[index];
                      return _buildProductCard(context, product);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel? product) {
    return GestureDetector(
      onTap: () {
        if (product != null) {
          context.push(Routes.productDetails, extra: product);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.inventory_2, size: 48, color: Colors.grey),
                    ),
                    if (product?.discountPrice != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SALE',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'Product Name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product?.shopName ?? 'Shop Name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          CurrencyFormatter.format(product?.discountPrice ?? product?.price ?? 0),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        if (product?.discountPrice != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            CurrencyFormatter.format(product!.price),
                            style: const TextStyle(
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
