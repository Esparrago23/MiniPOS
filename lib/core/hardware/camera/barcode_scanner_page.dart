import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'barcode_scanner_service.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key, required this.scannerService});

  final BarcodeScannerService scannerService;

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  late final MobileScannerController _controller;
  bool _isHandlingScan = false;

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
    if (_isHandlingScan) {
      return;
    }

    final code = widget.scannerService.readBarcode(capture);
    if (code == null) {
      return;
    }

    _isHandlingScan = true;

    try {
      await _controller.stop();
    } on MobileScannerException catch (error) {
      debugPrint(error.toString());
    }

    if (mounted) {
      Navigator.of(context).pop(code);
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
    } on MobileScannerException {
      _showCameraMessage('No se pudo cambiar la linterna.');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _controller.switchCamera();
    } on MobileScannerException {
      _showCameraMessage('No se pudo cambiar la camara.');
    }
  }

  void _showCameraMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear codigo'),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              final cameraReady = state.isInitialized && state.isRunning;
              final torchAvailable = state.torchState != TorchState.unavailable;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Linterna',
                    onPressed: cameraReady && torchAvailable
                        ? _toggleTorch
                        : null,
                    icon: Icon(
                      state.torchState == TorchState.on
                          ? Icons.flash_on
                          : Icons.flash_off,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cambiar camara',
                    onPressed: cameraReady ? _switchCamera : null,
                    icon: const Icon(Icons.cameraswitch_outlined),
                  ),
                ],
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
                icon: Icons.videocam_off_outlined,
                title: 'No se pudo abrir la camara',
                message: error.errorDetails?.message ?? error.errorCode.message,
              );
            },
            placeholderBuilder: (context) {
              return const _ScannerMessage(
                icon: Icons.camera_alt_outlined,
                title: 'Preparando camara',
                message: 'Acepta el permiso para poder escanear.',
              );
            },
          ),
          const _ScannerOverlay(),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.18)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 280,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.primary, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Alinea el codigo dentro del recuadro',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerMessage extends StatelessWidget {
  const _ScannerMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
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
              Icon(icon, color: Colors.white, size: 48),
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
