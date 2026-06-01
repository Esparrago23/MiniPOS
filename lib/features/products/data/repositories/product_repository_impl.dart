import 'package:app_prueba/core/network/api_client.dart';
import 'package:app_prueba/core/storage/token_storage.dart';
import 'package:app_prueba/features/products/data/datasources/remote/product_remote_datasource.dart';
import 'package:app_prueba/features/products/domain/entities/product.dart';
import 'package:app_prueba/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  const ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<List<Product>> getProducts() async {
    final token = await _requiredToken();
    return remoteDataSource.getProducts(token: token);
  }

  @override
  Future<Product> getProductById(int id) async {
    final token = await _requiredToken();
    return remoteDataSource.getProductById(id: id, token: token);
  }

  @override
  Future<Product> findProductByBarcode(String barcode) async {
    final token = await _requiredToken();
    return remoteDataSource.findProductByBarcode(
      barcode: barcode,
      token: token,
    );
  }

  @override
  Future<Product> createProduct({
    required String name,
    required String barcode,
    required double price,
    required int stock,
    String? category,
  }) async {
    final token = await _requiredToken();
    return remoteDataSource.createProduct(
      name: name,
      barcode: barcode,
      price: price,
      stock: stock,
      category: category,
      token: token,
    );
  }

  @override
  Future<Product> updateProduct({
    required int id,
    required String name,
    required String barcode,
    required double price,
    required int stock,
    String? category,
  }) async {
    final token = await _requiredToken();
    return remoteDataSource.updateProduct(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      stock: stock,
      category: category,
      token: token,
    );
  }

  @override
  Future<void> deleteProduct(int id) async {
    final token = await _requiredToken();
    return remoteDataSource.deleteProduct(id: id, token: token);
  }

  Future<String> _requiredToken() async {
    final token = await tokenStorage.readToken();

    if (token == null || token.isEmpty) {
      throw const ApiException('Inicia sesion para continuar.');
    }

    return token;
  }
}
