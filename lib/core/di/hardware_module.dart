import 'package:minipos/core/hardware/camera/barcode_scanner_service.dart';
import 'package:minipos/core/hardware/camera/mobile_barcode_scanner_service.dart';

class HardwareModule {
  HardwareModule() {
    barcodeScannerService = const MobileBarcodeScannerService();
  }

  late final BarcodeScannerService barcodeScannerService;
}
