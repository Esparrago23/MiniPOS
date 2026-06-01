import 'package:app_prueba/core/hardware/camera/barcode_scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/sales_viewmodel.dart';
import '../widgets/sale_cart_item_tile.dart';
import '../widgets/sale_total_bar.dart';
import 'sales_scanner_page.dart';
import 'sales_summary_page.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SalesViewModel>();
    final summary = viewModel.summary;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva venta')),
      body: SafeArea(
        child: summary.isEmpty
            ? _EmptySale(onStartScan: () => _openScanner(context))
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
                onPressed: () => _openSummary(context),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Continuar'),
              ),
            ),
      floatingActionButton: summary.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openScanner(context),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Ingresar producto'),
            ),
    );
  }

  Future<void> _openScanner(BuildContext context) async {
    final scannerService = context.read<BarcodeScannerService>();
    final continueToSummary = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SalesScannerPage(scannerService: scannerService),
      ),
    );

    if (!context.mounted || continueToSummary != true) {
      return;
    }

    await _openSummary(context);
  }

  Future<void> _openSummary(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SalesSummaryPage()));
  }

  void _showError(BuildContext context) {
    final message =
        context.read<SalesViewModel>().errorMessage ??
        'No se pudo actualizar la venta.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EmptySale extends StatelessWidget {
  const _EmptySale({required this.onStartScan});

  final VoidCallback onStartScan;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.point_of_sale,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Venta en curso',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Escanea productos y se iran agregando al carrito.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onStartScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Ingresar producto'),
            ),
          ],
        ),
      ),
    );
  }
}
