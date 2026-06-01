import '../entities/sale_cart_item.dart';

class UpdateSaleItemQuantityUseCase {
  const UpdateSaleItemQuantityUseCase();

  List<SaleCartItem> call({
    required List<SaleCartItem> currentItems,
    required int productId,
    required int quantity,
  }) {
    if (quantity <= 0) {
      throw ArgumentError('La cantidad debe ser mayor a 0.');
    }

    return currentItems.map((item) {
      if (item.product.id != productId) {
        return item;
      }

      if (quantity > item.product.stock) {
        throw ArgumentError('La cantidad supera el stock disponible.');
      }

      return item.copyWith(quantity: quantity);
    }).toList();
  }
}
