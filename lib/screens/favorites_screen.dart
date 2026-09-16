import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  int _calculateCrossAxisCount(double width) {
    if (width > 1250) return 5;
    if (width > 950) return 4;
    if (width > 650) return 3;
    if (width > 360) return 2;
    return 1;
  }

  double _calculateAspectRatio(double width) {
    if (width > 1250) return 0.76;
    if (width > 950) return 0.74;
    if (width > 650) return 0.72;
    if (width > 360) return 0.69;
    return 1.1;
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final theme = Theme.of(context);
    final favoriteProducts = favoritesProvider.favoriteProducts;

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
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
                    final childAspectRatio = _calculateAspectRatio(constraints.maxWidth);

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
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
              ),
            ),
    );
  }
}
