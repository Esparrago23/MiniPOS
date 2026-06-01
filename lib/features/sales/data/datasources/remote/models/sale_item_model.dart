import 'package:app_prueba/features/sales/domain/entities/sale_item.dart';

class SaleItemModel extends SaleItem {
  const SaleItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.barcode,
    required super.quantity,
    required super.unitPrice,
    required super.subtotal,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      barcode: json['barcode'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}
