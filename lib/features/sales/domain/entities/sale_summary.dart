import 'sale_cart_item.dart';

class SaleSummary {
  const SaleSummary({required this.items});

  final List<SaleCartItem> items;

  int get totalItems {
    return items.fold<int>(0, (total, item) => total + item.quantity);
  }

  double get total {
    return items.fold<double>(0, (total, item) => total + item.subtotal);
  }

  bool get isEmpty => items.isEmpty;
}
