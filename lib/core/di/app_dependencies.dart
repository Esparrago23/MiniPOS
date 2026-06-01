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
import 'package:app_prueba/features/products/data/datasources/remote/product_remote_datasource.dart';
import 'package:app_prueba/features/products/data/repositories/product_repository_impl.dart';
import 'package:app_prueba/features/products/domain/repositories/product_repository.dart';
import 'package:app_prueba/features/products/domain/usecases/create_product_usecase.dart';
import 'package:app_prueba/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:app_prueba/features/products/domain/usecases/find_product_by_barcode_usecase.dart';
import 'package:app_prueba/features/products/domain/usecases/get_product_by_id_usecase.dart';
import 'package:app_prueba/features/products/domain/usecases/get_products_usecase.dart';
import 'package:app_prueba/features/products/domain/usecases/update_product_usecase.dart';
import 'package:app_prueba/features/products/presentation/viewmodels/products_viewmodel.dart';
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
    productRemoteDataSource = ProductRemoteDataSource(apiClient: apiClient);
    productRepository = ProductRepositoryImpl(
      remoteDataSource: productRemoteDataSource,
      tokenStorage: tokenStorage,
    );
    productsViewModel = ProductsViewModel(
      getProductsUseCase: GetProductsUseCase(productRepository),
      getProductByIdUseCase: GetProductByIdUseCase(productRepository),
      findProductByBarcodeUseCase: FindProductByBarcodeUseCase(
        productRepository,
      ),
      createProductUseCase: CreateProductUseCase(productRepository),
      updateProductUseCase: UpdateProductUseCase(productRepository),
      deleteProductUseCase: DeleteProductUseCase(productRepository),
    );
  }

  late final http.Client _httpClient;
  late final TokenStorage tokenStorage;
  late final ApiClient apiClient;
  late final AuthRemoteDataSource authRemoteDataSource;
  late final AuthRepository authRepository;
  late final AuthViewModel authViewModel;
  late final ProductRemoteDataSource productRemoteDataSource;
  late final ProductRepository productRepository;
  late final ProductsViewModel productsViewModel;

  void dispose() {
    authViewModel.dispose();
    productsViewModel.dispose();
    _httpClient.close();
  }
}
