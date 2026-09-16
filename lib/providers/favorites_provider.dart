import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class FavoritesProvider extends ChangeNotifier {
  Set<int> _favoriteIds = {};
  List<Product> _favoriteProducts = [];

  Set<int> get favoriteIds => _favoriteIds;
  List<Product> get favoriteProducts => List.unmodifiable(_favoriteProducts);

  FavoritesProvider() {
    _loadFavorites();
  }

  void _loadFavorites() {
    _favoriteIds = StorageService.getFavoriteIds();
    _favoriteProducts = StorageService.getFavoriteProducts();
    notifyListeners();
  }

  bool isFavorite(int productId) {
    return _favoriteIds.contains(productId);
  }

  void toggleFavorite(Product product) async {
    if (_favoriteIds.contains(product.id)) {
      _favoriteIds.remove(product.id);
      _favoriteProducts.removeWhere((p) => p.id == product.id);
    } else {
      _favoriteIds.add(product.id);
      if (!_favoriteProducts.any((p) => p.id == product.id)) {
        _favoriteProducts.add(product);
      }
    }
    await StorageService.saveFavoriteIds(_favoriteIds);
    await StorageService.saveFavoriteProducts(_favoriteProducts);
    notifyListeners();
  }

  void toggleFavoriteById(int productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      _favoriteProducts.removeWhere((p) => p.id == productId);
    } else {
      _favoriteIds.add(productId);
    }
    await StorageService.saveFavoriteIds(_favoriteIds);
    await StorageService.saveFavoriteProducts(_favoriteProducts);
    notifyListeners();
  }
}
