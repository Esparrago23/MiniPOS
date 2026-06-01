class Product {
  final int id;
  final String name;
  final String barcode;
  final double price;
  final int stock;
  final String? category;

  const Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stock,
    this.category,
  });

  bool get hasStock => stock > 0;

  Product copyWith({
    int? id,
    String? name,
    String? barcode,
    double? price,
    int? stock,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
    );
  }
}
