import 'package:minipos/core/network/api_client.dart';
import 'package:minipos/core/network/api_endpoints.dart';

import 'models/sale_model.dart';

class SaleRemoteDataSource {
  const SaleRemoteDataSource({required this.apiClient});

  final ApiClient apiClient;

  Future<SaleModel> createSale({
    required List<Map<String, dynamic>> items,
    required String token,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.sales,
      token: token,
      body: {'items': items},
    );

    return SaleModel.fromJson(response);
  }
}
