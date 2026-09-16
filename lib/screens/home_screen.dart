import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/network_error_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductsProvider>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = context.watch<ProductsProvider>();
    final cartProvider = context.watch<CartProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store & Catalog'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: themeProvider.toggleTheme,
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: favoritesProvider.favoriteIds.isNotEmpty,
              label: Text('${favoritesProvider.favoriteIds.length}'),
              child: const Icon(Icons.favorite_border),
            ),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
            tooltip: 'Favorites',
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: cartProvider.totalItemCount > 0,
              label: Text('${cartProvider.totalItemCount}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            tooltip: 'Cart',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products by title or category...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            productsProvider.search('');
                          },
                        )
                      : null,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onSubmitted: (val) => productsProvider.search(val),
                onChanged: (val) {
                  if (val.isEmpty) productsProvider.search('');
                },
              ),
            ),

            // Category Horizontal Filter Chips
            if (productsProvider.categories.isNotEmpty)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: productsProvider.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = productsProvider.categories[index];
                    final isSelected = cat == productsProvider.selectedCategory;
                    return FilterChip(
                      label: Text(
                        cat[0].toUpperCase() + cat.substring(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => productsProvider.selectCategory(cat),
                    );
                  },
                ),
              ),

            // Network Error or Offline Mode Banner
            if (productsProvider.errorMessage != null)
              NetworkErrorBanner(
                message: productsProvider.errorMessage!,
                isOffline: productsProvider.isOffline,
                onRetry: () => productsProvider.fetchInitialProducts(),
                onDismiss: () => productsProvider.clearError(),
              ),

            // Product Grid / Shimmer / Empty State
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => productsProvider.refresh(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 900;
                    final isMedium = constraints.maxWidth > 600;
                    final crossAxisCount = isWide ? 4 : (isMedium ? 3 : 2);

                    if (productsProvider.isLoading &&
                        productsProvider.products.isEmpty) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: 6,
                        itemBuilder: (_, __) => const ProductCardShimmer(),
                      );
                    }

                    if (productsProvider.products.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(
                            height: constraints.maxHeight * 0.7,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: theme.colorScheme.outline,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No products found',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  FilledButton(
                                    onPressed: () => productsProvider.refresh(),
                                    child: const Text('Refresh Catalog'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = productsProvider.products[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/details',
                                      arguments: product,
                                    );
                                  },
                                );
                              },
                              childCount: productsProvider.products.length,
                            ),
                          ),
                        ),

                        // Infinite Scroll Loading Indicator
                        if (productsProvider.isLoadingMore)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),

                        if (!productsProvider.hasMore &&
                            productsProvider.products.isNotEmpty)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'You have reached the end of the catalog',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}