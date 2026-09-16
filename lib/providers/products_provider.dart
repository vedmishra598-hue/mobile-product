import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProductsProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isOffline = false;
  String? _errorMessage;

  static const int _pageSize = 10;
  int _currentSkip = 0;
  int _totalProducts = 0;

  List<Product> get products => _products;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;

  ProductsProvider() {
    init();
  }

  Future<void> init() async {
    await fetchCategories();
    await fetchInitialProducts();
  }

  Future<void> fetchCategories() async {
    try {
      final cats = await ApiService.getCategories();
      _categories = ['All', ...cats];
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchInitialProducts() async {
    _isLoading = true;
    _errorMessage = null;
    _isOffline = false;
    _currentSkip = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final result = await ApiService.getProducts(
        limit: _pageSize,
        skip: 0,
        category: _selectedCategory,
      );

      _products = result['products'] as List<Product>;
      _totalProducts = result['total'] as int;
      _currentSkip = _products.length;
      _hasMore = _products.length < _totalProducts;

      // Persist to Hive for offline cache
      await StorageService.saveCachedProducts(_products);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Fall back to Hive cached data for offline reading
      final cached = StorageService.getCachedProducts();
      if (cached.isNotEmpty) {
        _products = cached;
        _isOffline = true;
        _errorMessage = 'Offline mode: Showing cached data';
      } else {
        _errorMessage = e.toString();
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _searchQuery.isNotEmpty) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await ApiService.getProducts(
        limit: _pageSize,
        skip: _currentSkip,
        category: _selectedCategory,
      );

      final nextBatch = result['products'] as List<Product>;
      _products.addAll(nextBatch);
      _currentSkip += nextBatch.length;
      _hasMore = _products.length < _totalProducts && nextBatch.isNotEmpty;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _searchQuery = query.trim();
    if (_searchQuery.isEmpty) {
      await fetchInitialProducts();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await ApiService.searchProducts(_searchQuery);
      _products = results;
      _hasMore = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _searchQuery = '';
    fetchInitialProducts();
  }

  Future<void> refresh() async {
    _searchQuery = '';
    await fetchInitialProducts();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
