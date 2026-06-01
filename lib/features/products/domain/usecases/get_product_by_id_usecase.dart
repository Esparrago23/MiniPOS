import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductByIdUseCase {
  final ProductRepository repository;

  const GetProductByIdUseCase(this.repository);

  Future<Product> call(int id) {
    if (id <= 0) {
      throw ArgumentError('Product id must be greater than 0.');
    }

    return repository.getProductById(id);
  }
}
