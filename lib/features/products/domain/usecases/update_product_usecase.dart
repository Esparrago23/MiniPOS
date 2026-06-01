import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository repository;

  const UpdateProductUseCase(this.repository);

  Future<Product> call({
    required int id,
    required String name,
    required String barcode,
    required double price,
    required int stock,
    String? category,
  }) {
    if (id <= 0) {
      throw ArgumentError('Product id must be greater than 0.');
    }

    _validateProductData(
      name: name,
      barcode: barcode,
      price: price,
      stock: stock,
    );

    return repository.updateProduct(
      id: id,
      name: name.trim(),
      barcode: barcode.trim(),
      price: price,
      stock: stock,
      category: _cleanCategory(category),
    );
  }
}

void _validateProductData({
  required String name,
  required String barcode,
  required double price,
  required int stock,
}) {
  if (name.trim().isEmpty || barcode.trim().isEmpty) {
    throw ArgumentError('Name and barcode are required.');
  }

  if (price <= 0) {
    throw ArgumentError('Price must be greater than 0.');
  }

  if (stock < 0) {
    throw ArgumentError('Stock cannot be negative.');
  }
}

String? _cleanCategory(String? category) {
  final cleanCategory = category?.trim();
  return cleanCategory == null || cleanCategory.isEmpty ? null : cleanCategory;
}
