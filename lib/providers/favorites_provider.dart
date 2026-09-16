import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class FavoritesProvider extends ChangeNotifier {
  Set<int> _favoriteIds = {};

  Set<int> get favoriteIds => _favoriteIds;

  FavoritesProvider() {
    _loadFavorites();
  }

  void _loadFavorites() {
    _favoriteIds = StorageService.getFavoriteIds();
    notifyListeners();
  }

  bool isFavorite(int productId) {
    return _favoriteIds.contains(productId);
  }

  void toggleFavorite(int productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    await StorageService.saveFavoriteIds(_favoriteIds);
    notifyListeners();
  }
}
