class SaleItem {
  const SaleItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.barcode,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  final int id;
  final int productId;
  final String productName;
  final String barcode;
  final int quantity;
  final double unitPrice;
  final double subtotal;
}
