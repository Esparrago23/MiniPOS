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
                onPressed: viewModel.isSavingSale
                    ? null
                    : () => _submitSale(context),
                icon: viewModel.isSavingSale
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.payments_outlined),
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

  Future<void> _submitSale(BuildContext context) async {
    final viewModel = context.read<SalesViewModel>();
    final success = await viewModel.submitSale();

    if (!context.mounted) {
      return;
    }

    if (!success) {
      _showError(context);
      return;
    }

    final sale = viewModel.lastCompletedSale;
    if (sale == null) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Venta registrada'),
          content: Text(
            'Ticket #${sale.id}\n'
            'Productos: ${sale.items.length}\n'
            'Total: \$${sale.total.toStringAsFixed(2)}',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (context.mounted) {
      Navigator.of(context).pop();
    }
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
