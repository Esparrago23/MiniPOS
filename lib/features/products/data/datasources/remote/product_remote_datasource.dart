import 'package:minipos/core/network/api_client.dart';
import 'package:minipos/core/network/api_endpoints.dart';

import 'models/product_model.dart';

class ProductRemoteDataSource {
  final ApiClient apiClient;

  const ProductRemoteDataSource({required this.apiClient});

  Future<List<ProductModel>> getProducts({required String token}) async {
    final response = await apiClient.getList(
      ApiEndpoints.products,
      token: token,
    );

    return response
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel> getProductById({
    required int id,
    required String token,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.productById(id),
      token: token,
    );

    return ProductModel.fromJson(response);
  }

  Future<ProductModel> findProductByBarcode({
    required String barcode,
    required String token,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.productByBarcode(barcode),
      token: token,
    );

    return ProductModel.fromJson(response);
  }

  Future<ProductModel> createProduct({
    required String name,
    required String barcode,
    required double price,
    required int stock,
    required String token,
    String? category,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.products,
      token: token,
      body: {
        'name': name,
        'barcode': barcode,
        'price': price,
        'stock': stock,
        'category': category,
      },
    );

    return ProductModel.fromJson(response);
  }

  Future<ProductModel> updateProduct({
    required int id,
    required String name,
    required String barcode,
    required double price,
    required int stock,
    required String token,
    String? category,
  }) async {
    final response = await apiClient.put(
      ApiEndpoints.productById(id),
      token: token,
      body: {
        'name': name,
        'barcode': barcode,
        'price': price,
        'stock': stock,
        'category': category,
      },
    );

    return ProductModel.fromJson(response);
  }

  Future<void> deleteProduct({required int id, required String token}) async {
    await apiClient.delete(ApiEndpoints.productById(id), token: token);
  }
}
