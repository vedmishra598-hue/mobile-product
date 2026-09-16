import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/user_model.dart';

class StorageService {
  static const String productsBoxName = 'cached_products_box';
  static const String favoritesBoxName = 'favorites_box';
  static const String cartBoxName = 'cart_box';
  static const String authBoxName = 'auth_box';
  static const String settingsBoxName = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(productsBoxName);
    await Hive.openBox(favoritesBoxName);
    await Hive.openBox(cartBoxName);
    await Hive.openBox(authBoxName);
    await Hive.openBox(settingsBoxName);
  }

  // --- Cached Products for Offline Capability ---
  static Box get _productsBox => Hive.box(productsBoxName);

  static Future<void> saveCachedProducts(List<Product> products) async {
    final list = products.map((p) => jsonEncode(p.toJson())).toList();
    await _productsBox.put('products_cache', list);
  }

  static List<Product> getCachedProducts() {
    final raw = _productsBox.get('products_cache');
    if (raw == null) return [];
    try {
      final list = List<String>.from(raw as List);
      return list
          .map((item) => Product.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // --- Favorites Persistence ---
  static Box get _favoritesBox => Hive.box(favoritesBoxName);

  static Set<int> getFavoriteIds() {
    final raw = _favoritesBox.get('favorite_ids');
    if (raw == null) return {};
    try {
      final list = List<int>.from(raw as List);
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveFavoriteIds(Set<int> ids) async {
    await _favoritesBox.put('favorite_ids', ids.toList());
  }

  static List<Product> getFavoriteProducts() {
    final raw = _favoritesBox.get('favorite_products');
    if (raw == null) return [];
    try {
      final list = List<String>.from(raw as List);
      return list
          .map((item) => Product.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveFavoriteProducts(List<Product> products) async {
    final list = products.map((p) => jsonEncode(p.toJson())).toList();
    await _favoritesBox.put('favorite_products', list);
  }

  // --- Cart Persistence ---
  static Box get _cartBox => Hive.box(cartBoxName);

  static List<CartItem> getCartItems() {
    final raw = _cartBox.get('cart_items');
    if (raw == null) return [];
    try {
      final list = List<String>.from(raw as List);
      return list
          .map((item) => CartItem.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCartItems(List<CartItem> items) async {
    final list = items.map((i) => jsonEncode(i.toJson())).toList();
    await _cartBox.put('cart_items', list);
  }

  // --- Auth & User Tokens ---
  static Box get _authBox => Hive.box(authBoxName);

  static Future<void> saveUser(UserModel user) async {
    await _authBox.put('user_profile', jsonEncode(user.toJson()));
    await _authBox.put('auth_token', user.token);
  }

  static UserModel? getUser() {
    final raw = _authBox.get('user_profile');
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static String? getAuthToken() {
    return _authBox.get('auth_token') as String?;
  }

  static Future<void> clearAuth() async {
    await _authBox.delete('user_profile');
    await _authBox.delete('auth_token');
  }

  // --- Settings & Preferences ---
  static Box get _settingsBox => Hive.box(settingsBoxName);

  static bool isDarkMode() {
    return _settingsBox.get('is_dark_mode', defaultValue: false) as bool;
  }

  static Future<void> setDarkMode(bool value) async {
    await _settingsBox.put('is_dark_mode', value);
  }
}
