import 'package:app_prueba/core/hardware/camera/barcode_scanner_page.dart';
import 'package:app_prueba/core/hardware/camera/barcode_scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/product.dart';
import '../viewmodels/products_viewmodel.dart';
import '../widgets/product_text_field.dart';
import 'product_form_page.dart';

class ProductLookupPage extends StatefulWidget {
  const ProductLookupPage({super.key});

  @override
  State<ProductLookupPage> createState() => _ProductLookupPageState();
}

class _ProductLookupPageState extends State<ProductLookupPage> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final barcode = _barcodeController.text.trim();
    final viewModel = context.read<ProductsViewModel>();
    final product = await viewModel.findByBarcode(barcode);

    if (!mounted) {
      return;
    }

    if (product == null) {
      viewModel.clearError();
      await _showProductNotFound(context, barcode);
      return;
    }

    await _showProductActions(context, product);
  }

  Future<void> _scanWithCamera() async {
    FocusScope.of(context).unfocus();

    final scannerService = context.read<BarcodeScannerService>();
    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => BarcodeScannerPage(scannerService: scannerService),
      ),
    );

    if (!mounted || barcode == null || barcode.trim().isEmpty) {
      return;
    }

    _barcodeController.text = barcode.trim();
    await _search();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar producto')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Busca por codigo de barras',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Escanea el codigo con la camara o ingresalo manualmente.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ProductTextField(
                  controller: _barcodeController,
                  label: 'Codigo de barras',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.search,
                  validator: _requiredValidator,
                ),
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: viewModel.isLoading ? null : _scanWithCamera,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Escanear con camara'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: viewModel.isLoading ? null : _search,
                  icon: viewModel.isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showProductNotFound(
    BuildContext context,
    String barcode,
  ) async {
    final createProduct = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Producto no registrado'),
          content: Text('No existe un producto con el codigo $barcode.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Crear producto'),
            ),
          ],
        );
      },
    );

    if (createProduct != true || !context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductFormPage(initialBarcode: barcode),
      ),
    );
  }

  Future<void> _showProductActions(
    BuildContext context,
    Product product,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text('Codigo: ${product.barcode}'),
                Text('Precio: \$${product.price.toStringAsFixed(2)}'),
                Text('Stock: ${product.stock}'),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Ver precio'),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                ),
                ListTile(
                  leading: const Icon(Icons.add_box_outlined),
                  title: const Text('Agregar stock'),
                  onTap: () async {
                    Navigator.of(bottomSheetContext).pop();
                    await _showAddStockDialog(context, product);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Editar datos'),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProductFormPage(product: product),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: const Text('Eliminar producto'),
                  onTap: () async {
                    Navigator.of(bottomSheetContext).pop();
                    await _confirmDelete(context, product.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddStockDialog(
    BuildContext context,
    Product product,
  ) async {
    final quantityController = TextEditingController();

    final quantity = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar stock'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cantidad',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(int.tryParse(quantityController.text));
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );

    quantityController.dispose();

    if (quantity == null || quantity <= 0 || !context.mounted) {
      return;
    }

    await context.read<ProductsViewModel>().updateProduct(
      id: product.id,
      name: product.name,
      barcode: product.barcode,
      price: product.price,
      stock: product.stock + quantity,
      category: product.category,
    );
  }

  Future<void> _confirmDelete(BuildContext context, int productId) async {
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

    await context.read<ProductsViewModel>().deleteProduct(productId);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido';
    }
    return null;
  }
}
