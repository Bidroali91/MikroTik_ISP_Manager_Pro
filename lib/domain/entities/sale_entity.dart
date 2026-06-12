class SaleEntity {
  final String id;
  final String type;
  final int quantity;
  final double totalAmount;
  final DateTime createdAt;

  const SaleEntity({
    required this.id, this.type = 'voucher', this.quantity = 1,
    this.totalAmount = 0, required this.createdAt,
  });
}
