import 'sale_item.dart';

class Sale {
  const Sale({
    required this.id,
    required this.userId,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  final int id;
  final int userId;
  final double total;
  final DateTime createdAt;
  final List<SaleItem> items;
}
