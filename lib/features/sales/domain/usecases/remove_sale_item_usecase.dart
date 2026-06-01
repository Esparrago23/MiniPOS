import '../entities/sale_cart_item.dart';

class RemoveSaleItemUseCase {
  const RemoveSaleItemUseCase();

  List<SaleCartItem> call({
    required List<SaleCartItem> currentItems,
    required int productId,
  }) {
    return currentItems.where((item) => item.product.id != productId).toList();
  }
}
