import '../entities/sale_cart_item.dart';
import '../entities/sale_summary.dart';

class CalculateSaleSummaryUseCase {
  const CalculateSaleSummaryUseCase();

  SaleSummary call(List<SaleCartItem> items) {
    return SaleSummary(items: List.unmodifiable(items));
  }
}
