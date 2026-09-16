import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItemCount =>
      _items.fold(0, (total, current) => total + current.quantity);

  double get subtotal =>
      _items.fold(0.0, (total, current) => total + current.totalPrice);

  CartProvider() {
    _loadCart();
  }

  void _loadCart() {
    _items = StorageService.getCartItems();
    notifyListeners();
  }

  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    _saveAndNotify();
  }

  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _saveAndNotify();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      _saveAndNotify();
    }
  }

  void clearCart() {
    _items.clear();
    _saveAndNotify();
  }

  bool isInCart(int productId) {
    return _items.any((item) => item.product.id == productId);
  }

  Future<void> _saveAndNotify() async {
    await StorageService.saveCartItems(_items);
    notifyListeners();
  }
}
