import '../../../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.barcode,
    required super.price,
    required super.stock,
    super.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      barcode: json['barcode'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      category: json['category'] as String?,
    );
  }
}
