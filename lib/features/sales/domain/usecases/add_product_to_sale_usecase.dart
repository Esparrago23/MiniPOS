import 'package:app_prueba/features/products/domain/entities/product.dart';

import '../entities/sale_cart_item.dart';

class AddProductToSaleUseCase {
  const AddProductToSaleUseCase();

  List<SaleCartItem> call({
    required List<SaleCartItem> currentItems,
    required Product product,
    required int quantity,
  }) {
    _validateQuantity(quantity);

    final existingIndex = currentItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex == -1) {
      _validateStock(product: product, requestedQuantity: quantity);
      return [
        ...currentItems,
        SaleCartItem(product: product, quantity: quantity),
      ];
    }

    final updatedItems = [...currentItems];
    final existingItem = updatedItems[existingIndex];
    final newQuantity = existingItem.quantity + quantity;
    _validateStock(product: product, requestedQuantity: newQuantity);

    updatedItems[existingIndex] = existingItem.copyWith(quantity: newQuantity);
    return updatedItems;
  }
}

void _validateQuantity(int quantity) {
  if (quantity <= 0) {
    throw ArgumentError('La cantidad debe ser mayor a 0.');
  }
}

void _validateStock({
  required Product product,
  required int requestedQuantity,
}) {
  if (product.stock <= 0) {
    throw ArgumentError('No hay stock disponible para este producto.');
  }

  if (requestedQuantity > product.stock) {
    throw ArgumentError('La cantidad supera el stock disponible.');
  }
}
