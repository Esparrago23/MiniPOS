import 'package:flutter/material.dart';

import '../../domain/entities/sale_cart_item.dart';

class SaleCartItemTile extends StatelessWidget {
  const SaleCartItemTile({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final SaleCartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('Codigo: ${product.barcode}'),
                      Text('Disponible: ${product.stock}'),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('\$${product.price.toStringAsFixed(2)} c/u'),
                const Spacer(),
                IconButton.filledTonal(
                  tooltip: 'Quitar uno',
                  onPressed: item.quantity > 1
                      ? () => onQuantityChanged(item.quantity - 1)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    item.quantity.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Agregar uno',
                  onPressed: item.quantity < product.stock
                      ? () => onQuantityChanged(item.quantity + 1)
                      : null,
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(width: 12),
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
