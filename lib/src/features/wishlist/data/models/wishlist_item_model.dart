class WishlistItem {
  final String id;
  final String name;
  final double price;
  final String image;

  WishlistItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });

  // Convert from Map (Database)
  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['product_id'] ?? '', // Assuming we store product_id
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      image: map['image'] ?? '',
    );
  }

  // Convert to Map (Database)
  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id': userId,
      'product_id': id,
      'name': name,
      'price': price,
      'image': image,
    };
  }
}
