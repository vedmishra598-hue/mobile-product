import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final productsProvider = context.watch<ProductsProvider>();
    final theme = Theme.of(context);

    final favoriteProducts = productsProvider.products
        .where((p) => favoritesProvider.isFavorite(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Favorites'),
      ),
      body: favoriteProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites saved yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any product to save it offline.',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Discover Products'),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                final isMedium = constraints.maxWidth > 600;
                final crossAxisCount = isWide ? 4 : (isMedium ? 3 : 2);

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: favoriteProducts.length,
                  itemBuilder: (context, index) {
                    final product = favoriteProducts[index];
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
                );
              },
            ),
    );
  }
}
