import 'package:minipos/features/products/domain/entities/product.dart';

class SaleCartItem {
  const SaleCartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;

  SaleCartItem copyWith({Product? product, int? quantity}) {
    return SaleCartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
