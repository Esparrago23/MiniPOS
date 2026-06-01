import '../repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repository;

  const DeleteProductUseCase(this.repository);

  Future<void> call(int id) {
    if (id <= 0) {
      throw ArgumentError('Product id must be greater than 0.');
    }

    return repository.deleteProduct(id);
  }
}
