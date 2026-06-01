import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/sales_viewmodel.dart';
import '../widgets/sale_cart_item_tile.dart';
import '../widgets/sale_total_bar.dart';

class SalesSummaryPage extends StatelessWidget {
  const SalesSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SalesViewModel>();
    final summary = viewModel.summary;

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen de compra')),
      body: SafeArea(
        child: summary.isEmpty
            ? const _EmptySummary()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: viewModel.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = viewModel.items[index];
                  return SaleCartItemTile(
                    item: item,
                    onQuantityChanged: (quantity) {
                      final success = context
                          .read<SalesViewModel>()
                          .updateQuantity(item.product.id, quantity);
                      if (!success) {
                        _showError(context);
                      }
                    },
                    onRemove: () {
                      context.read<SalesViewModel>().removeProduct(
                        item.product.id,
                      );
                    },
                  );
                },
              ),
      ),
      bottomNavigationBar: summary.isEmpty
          ? null
          : SaleTotalBar(
              summary: summary,
              action: FilledButton.icon(
                onPressed: () => _showPendingDataMessage(context),
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Cobrar'),
              ),
            ),
    );
  }

  void _showError(BuildContext context) {
    final message =
        context.read<SalesViewModel>().errorMessage ??
        'No se pudo actualizar la venta.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showPendingDataMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Falta conectar sales/data para guardar la venta.'),
      ),
    );
  }
}

class _EmptySummary extends StatelessWidget {
  const _EmptySummary();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin productos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega productos para generar el resumen.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
