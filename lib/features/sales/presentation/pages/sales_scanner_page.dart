import 'dart:async';

import 'package:minipos/core/hardware/camera/barcode_scanner_service.dart';
import 'package:minipos/features/products/domain/entities/product.dart';
import 'package:minipos/features/products/presentation/pages/product_form_page.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../viewmodels/sales_viewmodel.dart';
import '../widgets/sale_total_bar.dart';

enum _MissingProductAction { register, continueScanning }

class SalesScannerPage extends StatefulWidget {
  const SalesScannerPage({super.key, required this.scannerService});

  final BarcodeScannerService scannerService;

  @override
  State<SalesScannerPage> createState() => _SalesScannerPageState();
}

class _SalesScannerPageState extends State<SalesScannerPage> {
  late final MobileScannerController _controller;
  bool _isHandlingScan = false;
  bool _isClosing = false;
  String? _ignoredBarcode;

  @override
  void initState() {
    super.initState();
    _controller = widget.scannerService.createController();
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  Future<void> _handleCapture(BarcodeCapture capture) async {
    if (_isHandlingScan || _isClosing) {
      return;
    }

    final barcode = widget.scannerService.readBarcode(capture);
    if (barcode == null) {
      return;
    }

    if (barcode == _ignoredBarcode) {
      return;
    }

    if (_ignoredBarcode != null && barcode != _ignoredBarcode) {
      _ignoredBarcode = null;
    }

    await _processBarcode(barcode);
  }

  Future<void> _processBarcode(String barcode) async {
    _isHandlingScan = true;
    final viewModel = context.read<SalesViewModel>();

    try {
      await _controller.stop();
    } on MobileScannerException catch (error) {
      debugPrint(error.toString());
    }

    final product = await viewModel.findProductByBarcode(barcode);

    if (!mounted) {
      return;
    }

    if (product == null) {
      await _handleMissingProduct(barcode, viewModel);
    } else {
      _ignoredBarcode = null;
      await _showProductPreview(product);
    }

    if (mounted && !_isClosing) {
      try {
        await _controller.start();
      } on MobileScannerException {
        _showMessage('No se pudo reactivar la camara.');
      }
    }

    _isHandlingScan = false;
  }

  Future<void> _handleMissingProduct(
    String barcode,
    SalesViewModel viewModel,
  ) async {
    final action = await showDialog<_MissingProductAction>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Producto no registrado'),
          content: Text(
            'No existe un producto con el codigo $barcode. '
            'Puedes registrarlo ahora o continuar escaneando.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_MissingProductAction.continueScanning),
              child: const Text('No registrar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_MissingProductAction.register),
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (action != _MissingProductAction.register) {
      _ignoredBarcode = barcode;
      viewModel.clearError();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductFormPage(initialBarcode: barcode),
      ),
    );

    if (!mounted) {
      return;
    }

    final registeredProduct = await viewModel.findProductByBarcode(barcode);

    if (!mounted) {
      return;
    }

    if (registeredProduct == null) {
      _ignoredBarcode = barcode;
      _showMessage('El producto no fue registrado.');
      return;
    }

    _ignoredBarcode = null;
    await _showProductPreview(registeredProduct);
  }

  Future<void> _showProductPreview(Product product) async {
    final quantityController = TextEditingController(text: '1');
    var quantity = 1;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final quantityInCart = context
                .read<SalesViewModel>()
                .quantityInCart(product.id);
            final availableToAdd = product.stock - quantityInCart;

            void updateQuantity(int nextQuantity) {
              final cleanQuantity = nextQuantity.clamp(1, availableToAdd);
              quantity = cleanQuantity;
              quantityController.text = cleanQuantity.toString();
              setSheetState(() {});
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Confirmar producto',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: Text(product.name),
                      subtitle: Text(
                        'Codigo: ${product.barcode}\n'
                        'Precio: \$${product.price.toStringAsFixed(2)}\n'
                        'Disponible: $availableToAdd',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Quitar uno',
                          onPressed: quantity > 1
                              ? () => updateQuantity(quantity - 1)
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              final parsed = int.tryParse(value);
                              if (parsed == null) {
                                return;
                              }
                              quantity = parsed;
                              setSheetState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          tooltip: 'Agregar uno',
                          onPressed: quantity < availableToAdd
                              ? () => updateQuantity(quantity + 1)
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.of(bottomSheetContext).pop(),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: availableToAdd <= 0
                                ? null
                                : () => _addProduct(
                                    bottomSheetContext,
                                    product,
                                    quantity,
                                  ),
                            child: const Text('Anadir'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    quantityController.dispose();
  }

  void _addProduct(
    BuildContext bottomSheetContext,
    Product product,
    int quantity,
  ) {
    final success = context.read<SalesViewModel>().addProduct(
      product,
      quantity,
    );

    if (!success) {
      _showMessage(
        context.read<SalesViewModel>().errorMessage ??
            'No se pudo agregar el producto.',
      );
      return;
    }

    Navigator.of(bottomSheetContext).pop();
    _showMessage('Producto agregado.');
  }

  Future<void> _openManualEntry() async {
    try {
      await _controller.stop();
    } on MobileScannerException catch (error) {
      debugPrint(error.toString());
    }

    if (!mounted) {
      return;
    }

    final controller = TextEditingController();
    final barcode = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ingresar codigo'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Codigo de barras',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Buscar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted) {
      return;
    }

    final cleanBarcode = barcode?.trim();
    if (cleanBarcode != null && cleanBarcode.isNotEmpty) {
      await _processBarcode(cleanBarcode);
      return;
    }

    try {
      await _controller.start();
    } on MobileScannerException {
      _showMessage('No se pudo reactivar la camara.');
    }
  }

  Future<void> _continueToSummary() async {
    _isClosing = true;

    try {
      await _controller.stop();
    } on MobileScannerException catch (error) {
      debugPrint(error.toString());
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SalesViewModel>();
    final summary = viewModel.summary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresar productos'),
        actions: [
          IconButton(
            tooltip: 'Ingresar codigo',
            onPressed: _isHandlingScan ? null : _openManualEntry,
            icon: const Icon(Icons.keyboard_alt_outlined),
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              final cameraReady = state.isInitialized && state.isRunning;
              final torchAvailable = state.torchState != TorchState.unavailable;

              return IconButton(
                tooltip: 'Linterna',
                onPressed: cameraReady && torchAvailable
                    ? _controller.toggleTorch
                    : null,
                icon: Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleCapture,
            errorBuilder: (context, error) {
              return _ScannerMessage(
                title: 'No se pudo abrir la camara',
                message: error.errorDetails?.message ?? error.errorCode.message,
              );
            },
            placeholderBuilder: (context) {
              return const _ScannerMessage(
                title: 'Preparando camara',
                message: 'Acepta el permiso para escanear productos.',
              );
            },
          ),
          const _SalesScannerOverlay(),
        ],
      ),
      bottomNavigationBar: SaleTotalBar(
        summary: summary,
        action: FilledButton.icon(
          onPressed: summary.isEmpty ? null : _continueToSummary,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Continuar'),
        ),
      ),
    );
  }
}

class _SalesScannerOverlay extends StatelessWidget {
  const _SalesScannerOverlay();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.16)),
        child: Center(
          child: Container(
            width: 280,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.primary, width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScannerMessage extends StatelessWidget {
  const _ScannerMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_outlined,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
