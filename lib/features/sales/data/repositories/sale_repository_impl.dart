import 'package:app_prueba/core/network/api_client.dart';
import 'package:app_prueba/core/storage/token_storage.dart';
import 'package:app_prueba/features/sales/data/datasources/remote/sale_remote_datasource.dart';
import 'package:app_prueba/features/sales/domain/entities/sale.dart';
import 'package:app_prueba/features/sales/domain/entities/sale_cart_item.dart';
import 'package:app_prueba/features/sales/domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  const SaleRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  final SaleRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  @override
  Future<Sale> createSale(List<SaleCartItem> items) async {
    final token = await _requiredToken();
    final requestItems = items
        .map(
          (item) => {'product_id': item.product.id, 'quantity': item.quantity},
        )
        .toList();

    return remoteDataSource.createSale(items: requestItems, token: token);
  }

  Future<String> _requiredToken() async {
    final token = await tokenStorage.readToken();

    if (token == null || token.isEmpty) {
      throw const ApiException('Inicia sesion para continuar.');
    }

    return token;
  }
}
