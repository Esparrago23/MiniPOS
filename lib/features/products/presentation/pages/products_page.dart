import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/products_viewmodel.dart';
import '../widgets/product_card.dart';
import 'product_form_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsViewModel>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            tooltip: 'Recargar productos',
            onPressed: viewModel.isLoading ? null : viewModel.loadProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(context, viewModel),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.isLoading
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProductFormPage(),
                  ),
                );
              },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductsViewModel viewModel) {
    if (viewModel.isLoading && viewModel.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.status == ProductsStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                viewModel.errorMessage ?? 'No se pudieron cargar productos.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: viewModel.loadProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Todavia no hay productos registrados.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final product = viewModel.products[index];

        return ProductCard(
          product: product,
          onEdit: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProductFormPage(product: product),
              ),
            );
          },
          onDelete: viewModel.isLoading
              ? null
              : () => _confirmDelete(context, viewModel, product.id),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProductsViewModel viewModel,
    int productId,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: const Text('Esta accion no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    await viewModel.deleteProduct(productId);
  }
}
