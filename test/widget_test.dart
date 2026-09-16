import 'package:flutter_test/flutter_test.dart';
import 'package:offline_first_mobile_product_slice/models/product.dart';
import 'package:offline_first_mobile_product_slice/models/cart_item.dart';
import 'package:offline_first_mobile_product_slice/models/user_model.dart';

void main() {
  group('Data Models & Serialization Tests', () {
    test('Product JSON serialization and deserialization works correctly', () {
      final json = {
        'id': 101,
        'title': 'Wireless Noise-Cancelling Headphones',
        'description': 'High fidelity premium sound',
        'price': 199.99,
        'rating': 4.8,
        'category': 'audio',
        'thumbnail': 'https://example.com/headphones.jpg',
        'stock': 25,
      };

      final product = Product.fromJson(json);

      expect(product.id, 101);
      expect(product.title, 'Wireless Noise-Cancelling Headphones');
      expect(product.price, 199.99);
      expect(product.rating, 4.8);
      expect(product.category, 'audio');
      expect(product.stock, 25);

      final encoded = product.toJson();
      expect(encoded['id'], 101);
      expect(encoded['title'], 'Wireless Noise-Cancelling Headphones');
      expect(encoded['price'], 199.99);
    });

    test('CartItem calculates totalPrice and serializes properly', () {
      final product = Product(
        id: 1,
        title: 'Smartphone Stand',
        description: 'Adjustable aluminum desktop mount',
        price: 25.00,
        rating: 4.5,
        category: 'accessories',
        thumbnail: 'https://example.com/stand.jpg',
        stock: 50,
      );

      final cartItem = CartItem(product: product, quantity: 3);

      expect(cartItem.totalPrice, 75.00);

      final serialized = cartItem.toJson();
      final deserialized = CartItem.fromJson(serialized);

      expect(deserialized.product.id, 1);
      expect(deserialized.quantity, 3);
      expect(deserialized.totalPrice, 75.00);
    });

    test('UserModel serializes auth token and user credentials', () {
      final user = UserModel(
        id: 'usr_42',
        name: 'Jordan Lee',
        email: 'jordan@example.com',
        token: 'secret_jwt_token_xyz',
        avatar: 'https://example.com/avatar.png',
      );

      final json = user.toJson();
      expect(json['token'], 'secret_jwt_token_xyz');
      expect(json['name'], 'Jordan Lee');

      final reconstructed = UserModel.fromJson(json);
      expect(reconstructed.id, 'usr_42');
      expect(reconstructed.token, 'secret_jwt_token_xyz');
      expect(reconstructed.email, 'jordan@example.com');
    });
  });
}
