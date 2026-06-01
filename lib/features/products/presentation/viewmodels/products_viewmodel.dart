import 'package:flutter/foundation.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/find_product_by_barcode_usecase.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';

enum ProductsStatus { initial, loading, success, empty, error }

class ProductsViewModel extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final GetProductByIdUseCase getProductByIdUseCase;
  final FindProductByBarcodeUseCase findProductByBarcodeUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  ProductsViewModel({
    required this.getProductsUseCase,
    required this.getProductByIdUseCase,
    required this.findProductByBarcodeUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  });

  ProductsStatus _status = ProductsStatus.initial;
  List<Product> _products = [];
  Product? _selectedProduct;
  String? _errorMessage;

  ProductsStatus get status => _status;
  List<Product> get products => List.unmodifiable(_products);
  Product? get selectedProduct => _selectedProduct;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ProductsStatus.loading;

  Future<void> loadProducts() async {
    _setLoading();

    try {
      _products = await getProductsUseCase();
      _status = _products.isEmpty
          ? ProductsStatus.empty
          : ProductsStatus.success;
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _setError(error);
    }
  }

  Future<void> loadProductById(int id) async {
    _setLoading();

    try {
      _selectedProduct = await getProductByIdUseCase(id);
      _status = ProductsStatus.success;
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _setError(error);
    }
  }

  Future<Product?> findByBarcode(String barcode) async {
    _setLoading();

    try {
      final product = await findProductByBarcodeUseCase(barcode);
      _selectedProduct = product;
      _status = ProductsStatus.success;
      _errorMessage = null;
      notifyListeners();
      return product;
    } catch (error) {
      _setError(error);
      return null;
    }
  }

  Future<bool> createProduct({
    required String name,
    required String barcode,
    required double price,
    required int stock,
    String? category,
  }) async {
    _setLoading();

    try {
      final product = await createProductUseCase(
        name: name,
        barcode: barcode,
        price: price,
        stock: stock,
        category: category,
      );
      _products = [..._products, product]
        ..sort((a, b) => a.name.compareTo(b.name));
      _status = ProductsStatus.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  Future<bool> updateProduct({
    required int id,
    required String name,
    required String barcode,
    required double price,
    required int stock,
    String? category,
  }) async {
    _setLoading();

    try {
      final updatedProduct = await updateProductUseCase(
        id: id,
        name: name,
        barcode: barcode,
        price: price,
        stock: stock,
        category: category,
      );

      _products =
          _products
              .map((product) => product.id == id ? updatedProduct : product)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      _selectedProduct = updatedProduct;
      _status = ProductsStatus.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    _setLoading();

    try {
      await deleteProductUseCase(id);
      _products = _products.where((product) => product.id != id).toList();
      if (_selectedProduct?.id == id) {
        _selectedProduct = null;
      }
      _status = _products.isEmpty
          ? ProductsStatus.empty
          : ProductsStatus.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == ProductsStatus.error) {
      _status = _products.isEmpty
          ? ProductsStatus.initial
          : ProductsStatus.success;
    }
    notifyListeners();
  }

  void _setLoading() {
    _status = ProductsStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(Object error) {
    _status = ProductsStatus.error;
    _errorMessage = error.toString();
    notifyListeners();
  }
}
