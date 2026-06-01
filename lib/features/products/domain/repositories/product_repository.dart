import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();

  Future<Product> getProductById(int id);

  Future<Product> findProductByBarcode(String barcode);

  Future<Product> createProduct({
    required String name,
    required String barcode,
    required double price,
    required int stock,
    String? category,
  });

  Future<Product> updateProduct({
    required int id,
    required String name,
    required String barcode,
    required double price,
    required int stock,
    String? category,
  });

  Future<void> deleteProduct(int id);
}
