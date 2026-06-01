import 'package:app_prueba/core/network/api_client.dart';
import 'package:app_prueba/core/network/api_endpoints.dart';

import 'models/auth_response_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  const AuthRemoteDataSource({required this.apiClient});

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
    );

    return AuthResponseModel.fromJson(response);
  }

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.register,
      body: {'name': name, 'email': email, 'password': password},
    );

    return AuthResponseModel.fromJson(response);
  }
}
