class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final String category;
  final String thumbnail;
  final int stock;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.category,
    required this.thumbnail,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'General',
      thumbnail: json['thumbnail'] as String? ??
          (json['images'] is List && (json['images'] as List).isNotEmpty
              ? json['images'][0]
              : 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80'),
      stock: json['stock'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'rating': rating,
      'category': category,
      'thumbnail': thumbnail,
      'stock': stock,
    };
  }
}
