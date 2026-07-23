import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/admin_product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/customer_order_provider.dart';
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
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${user?.fullName ?? 'Guest'}!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.cart),
            icon: Consumer<CartProvider>(
              builder: (context, cart, _) => Badge.count(
                count: cart.items.length,
                isLabelVisible: cart.items.isNotEmpty,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
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
              // Order Summary
              SliverToBoxAdapter(
                child: _buildOrderSummary(context),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SearchBar(
                    hintText: 'Search products, shops...',
                    leading: const Icon(Icons.search),
                    onTap: () => context.push(Routes.search),
                    readOnly: true,
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
                            onPressed: () => context.push(Routes.allShops),
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
                            height: 170,
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

              // Recommended Products (Featured)
              _buildProductSection(
                title: 'Recommended for You',
                filter: (products) => products.where((p) => p.minStockAlert > 0).toList(), // Using minStockAlert as placeholder for featured logic if no isFeatured flag
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Recent Products
              _buildProductSection(
                title: 'Recent Products',
                filter: (products) {
                  final sorted = List<ProductModel>.from(products);
                  sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  return sorted.take(10).toList();
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel? category) {
    return GestureDetector(
      onTap: () {
        if (category != null) {
          context.push(Routes.search, extra: category.name);
        }
      },
      child: Padding(
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
              Expanded(
                child: Padding(
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
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey, size: 12),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              shop?.address ?? '', 
                              style: const TextStyle(fontSize: 11), 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                  onPressed: () => context.push(Routes.search),
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
                  height: 230,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?.name ?? 'Product Name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product?.shopName ?? 'Shop Name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  CurrencyFormatter.format(product?.discountPrice ?? product?.price ?? 0),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (product?.discountPrice != null) ...[
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    CurrencyFormatter.format(product!.price),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
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

  Widget _buildOrderSummary(BuildContext context) {
    return Consumer<CustomerOrderProvider>(
      builder: (context, provider, _) {
        final activeOrders = provider.orders.where((o) => o.status != 'delivered' && o.status != 'cancelled').length;
        if (activeOrders == 0) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: InkWell(
            onTap: () => context.push(Routes.orderHistory),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withAlpha(51)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delivery_dining, color: Colors.blue),
                  const SizedBox(width: 12),
                  Text(
                    'You have $activeOrders active orders',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const Spacer(),
                  const Text('Track', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  const Icon(Icons.chevron_right, color: Colors.blue, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
