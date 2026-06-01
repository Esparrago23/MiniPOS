import '../entities/product.dart';
import '../repositories/product_repository.dart';

class FindProductByBarcodeUseCase {
  final ProductRepository repository;

  const FindProductByBarcodeUseCase(this.repository);

  Future<Product> call(String barcode) {
    final cleanBarcode = barcode.trim();

    if (cleanBarcode.isEmpty) {
      throw ArgumentError('Barcode is required.');
    }

    return repository.findProductByBarcode(cleanBarcode);
  }
}
