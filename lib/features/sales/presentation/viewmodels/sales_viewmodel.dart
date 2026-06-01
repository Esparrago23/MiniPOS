import 'package:app_prueba/features/products/domain/entities/product.dart';
import 'package:app_prueba/features/products/domain/usecases/find_product_by_barcode_usecase.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/sale_cart_item.dart';
import '../../domain/entities/sale_summary.dart';
import '../../domain/usecases/add_product_to_sale_usecase.dart';
import '../../domain/usecases/calculate_sale_summary_usecase.dart';
import '../../domain/usecases/remove_sale_item_usecase.dart';
import '../../domain/usecases/update_sale_item_quantity_usecase.dart';

enum SalesStatus { initial, loadingProduct, ready, error }

class SalesViewModel extends ChangeNotifier {
  SalesViewModel({
    required this.findProductByBarcodeUseCase,
    required this.addProductToSaleUseCase,
    required this.updateSaleItemQuantityUseCase,
    required this.removeSaleItemUseCase,
    required this.calculateSaleSummaryUseCase,
  });

  final FindProductByBarcodeUseCase findProductByBarcodeUseCase;
  final AddProductToSaleUseCase addProductToSaleUseCase;
  final UpdateSaleItemQuantityUseCase updateSaleItemQuantityUseCase;
  final RemoveSaleItemUseCase removeSaleItemUseCase;
  final CalculateSaleSummaryUseCase calculateSaleSummaryUseCase;

  SalesStatus _status = SalesStatus.initial;
  List<SaleCartItem> _items = [];
  Product? _lastScannedProduct;
  String? _errorMessage;

  SalesStatus get status => _status;
  List<SaleCartItem> get items => List.unmodifiable(_items);
  Product? get lastScannedProduct => _lastScannedProduct;
  String? get errorMessage => _errorMessage;
  bool get isLoadingProduct => _status == SalesStatus.loadingProduct;
  bool get hasItems => _items.isNotEmpty;
  SaleSummary get summary => calculateSaleSummaryUseCase(_items);

  int quantityInCart(int productId) {
    for (final item in _items) {
      if (item.product.id == productId) {
        return item.quantity;
      }
    }

    return 0;
  }

  Future<Product?> findProductByBarcode(String barcode) async {
    _status = SalesStatus.loadingProduct;
    _errorMessage = null;
    notifyListeners();

    try {
      final product = await findProductByBarcodeUseCase(barcode);
      _lastScannedProduct = product;
      _status = SalesStatus.ready;
      notifyListeners();
      return product;
    } catch (_) {
      _lastScannedProduct = null;
      _status = SalesStatus.error;
      _errorMessage = 'Producto no encontrado en inventario.';
      notifyListeners();
      return null;
    }
  }

  bool addProduct(Product product, int quantity) {
    try {
      _items = addProductToSaleUseCase(
        currentItems: _items,
        product: product,
        quantity: quantity,
      );
      _status = SalesStatus.ready;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  bool updateQuantity(int productId, int quantity) {
    try {
      _items = updateSaleItemQuantityUseCase(
        currentItems: _items,
        productId: productId,
        quantity: quantity,
      );
      _status = _items.isEmpty ? SalesStatus.initial : SalesStatus.ready;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  void removeProduct(int productId) {
    _items = removeSaleItemUseCase(currentItems: _items, productId: productId);
    _status = _items.isEmpty ? SalesStatus.initial : SalesStatus.ready;
    _errorMessage = null;
    notifyListeners();
  }

  void clearSale() {
    _items = [];
    _lastScannedProduct = null;
    _status = SalesStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == SalesStatus.error) {
      _status = _items.isEmpty ? SalesStatus.initial : SalesStatus.ready;
    }
    notifyListeners();
  }

  void _setError(Object error) {
    _status = SalesStatus.error;
    _errorMessage = error.toString().replaceFirst('Invalid argument(s): ', '');
    notifyListeners();
  }
}
