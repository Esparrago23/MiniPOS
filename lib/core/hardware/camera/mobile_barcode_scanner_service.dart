import 'package:mobile_scanner/mobile_scanner.dart';

import 'barcode_scanner_service.dart';

class MobileBarcodeScannerService implements BarcodeScannerService {
  const MobileBarcodeScannerService();

  @override
  MobileScannerController createController() {
    return MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.code128,
      ],
    );
  }

  @override
  String? readBarcode(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }
}
