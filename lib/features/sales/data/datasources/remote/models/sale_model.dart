import 'package:app_prueba/features/sales/domain/entities/sale.dart';

import 'sale_item_model.dart';

class SaleModel extends Sale {
  const SaleModel({
    required super.id,
    required super.userId,
    required super.total,
    required super.createdAt,
    required super.items,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>;

    return SaleModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      items: rawItems
          .map((item) => SaleItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
