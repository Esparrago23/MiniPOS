import '../entities/sale.dart';
import '../entities/sale_cart_item.dart';

abstract class SaleRepository {
  Future<Sale> createSale(List<SaleCartItem> items);
}
