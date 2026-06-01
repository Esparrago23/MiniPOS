import 'package:mobile_scanner/mobile_scanner.dart';

abstract class BarcodeScannerService {
  MobileScannerController createController();

  String? readBarcode(BarcodeCapture capture);
}
