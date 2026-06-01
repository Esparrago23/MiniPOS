import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: product.hasStock
              ? colorScheme.primaryContainer
              : colorScheme.errorContainer,
          foregroundColor: product.hasStock
              ? colorScheme.onPrimaryContainer
              : colorScheme.onErrorContainer,
          child: const Icon(Icons.inventory_2_outlined),
        ),
        title: Text(product.name),
        subtitle: Text(
          '${product.barcode}\nStock: ${product.stock}'
          '${product.category == null ? '' : ' · ${product.category}'}',
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              tooltip: 'Editar producto',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Eliminar producto',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
