import 'package:app_prueba/core/network/api_client.dart';
import 'package:app_prueba/core/network/api_endpoints.dart';
import 'package:app_prueba/core/storage/token_storage.dart';
import 'package:app_prueba/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:app_prueba/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app_prueba/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_prueba/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_prueba/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_prueba/features/auth/domain/usecases/register_usecase.dart';
import 'package:app_prueba/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:http/http.dart' as http;

class AppDependencies {
  AppDependencies() {
    _httpClient = http.Client();
    tokenStorage = InMemoryTokenStorage();
    apiClient = ApiClient(client: _httpClient, baseUrl: ApiEndpoints.baseUrl);
    authRemoteDataSource = AuthRemoteDataSource(apiClient: apiClient);
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      tokenStorage: tokenStorage,
    );
    authViewModel = AuthViewModel(
      loginUseCase: LoginUseCase(authRepository),
      registerUseCase: RegisterUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
    );
  }

  late final http.Client _httpClient;
  late final TokenStorage tokenStorage;
  late final ApiClient apiClient;
  late final AuthRemoteDataSource authRemoteDataSource;
  late final AuthRepository authRepository;
  late final AuthViewModel authViewModel;

  void dispose() {
    authViewModel.dispose();
    _httpClient.close();
  }
}
