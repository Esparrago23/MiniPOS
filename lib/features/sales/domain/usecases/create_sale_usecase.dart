import '../entities/sale.dart';
import '../entities/sale_cart_item.dart';
import '../repositories/sale_repository.dart';

class CreateSaleUseCase {
  const CreateSaleUseCase(this.repository);

  final SaleRepository repository;

  Future<Sale> call(List<SaleCartItem> items) {
    if (items.isEmpty) {
      throw ArgumentError('La venta debe tener al menos un producto.');
    }

    for (final item in items) {
      if (item.quantity <= 0) {
        throw ArgumentError('La cantidad debe ser mayor a 0.');
      }
    }

    return repository.createSale(items);
  }
}
