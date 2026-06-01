import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/product.dart';
import '../viewmodels/products_viewmodel.dart';
import '../widgets/product_text_field.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _nameController.text = product.name;
      _barcodeController.text = product.barcode;
      _priceController.text = product.price.toStringAsFixed(2);
      _stockController.text = product.stock.toString();
      _categoryController.text = product.category ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<ProductsViewModel>();
    final price = double.parse(_priceController.text);
    final stock = int.parse(_stockController.text);
    final product = widget.product;

    final success = product == null
        ? await viewModel.createProduct(
            name: _nameController.text,
            barcode: _barcodeController.text,
            price: price,
            stock: stock,
            category: _categoryController.text,
          )
        : await viewModel.updateProduct(
            id: product.id,
            name: _nameController.text,
            barcode: _barcodeController.text,
            price: price,
            stock: stock,
            category: _categoryController.text,
          );

    if (!mounted || !success) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProductTextField(
                  controller: _nameController,
                  label: 'Nombre',
                  icon: Icons.inventory_2_outlined,
                  textInputAction: TextInputAction.next,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 16),
                ProductTextField(
                  controller: _barcodeController,
                  label: 'Codigo de barras',
                  icon: Icons.qr_code_scanner,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 16),
                ProductTextField(
                  controller: _priceController,
                  label: 'Precio',
                  icon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _priceValidator,
                ),
                const SizedBox(height: 16),
                ProductTextField(
                  controller: _stockController,
                  label: 'Stock',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: _stockValidator,
                ),
                const SizedBox(height: 16),
                ProductTextField(
                  controller: _categoryController,
                  label: 'Categoria',
                  icon: Icons.category_outlined,
                  textInputAction: TextInputAction.done,
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
                FilledButton.icon(
                  onPressed: viewModel.isLoading ? null : _submit,
                  icon: viewModel.isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isEditing ? 'Guardar cambios' : 'Crear producto',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido';
    }
    return null;
  }

  String? _priceValidator(String? value) {
    final price = double.tryParse(value ?? '');
    if (price == null || price <= 0) {
      return 'Ingresa un precio valido';
    }
    return null;
  }

  String? _stockValidator(String? value) {
    final stock = int.tryParse(value ?? '');
    if (stock == null || stock < 0) {
      return 'Ingresa un stock valido';
    }
    return null;
  }
}
