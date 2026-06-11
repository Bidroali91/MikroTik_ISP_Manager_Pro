class SaleModel {
  final String id;
  final String userId;
  final String routerId;
  final String type;
  final String? profile;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final DateTime createdAt;

  SaleModel({
    required this.id, required this.userId, required this.routerId,
    this.type = 'voucher', this.profile, this.quantity = 1,
    this.unitPrice = 0, this.totalAmount = 0, this.customerName,
    this.customerPhone, this.notes, DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SaleModel.fromMap(String id, Map<String, dynamic> map) => SaleModel(
    id: id, userId: map['userId'] ?? '', routerId: map['routerId'] ?? '',
    type: map['type'] ?? 'voucher', profile: map['profile'],
    quantity: map['quantity'] ?? 1, unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
    totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0,
    customerName: map['customerName'], customerPhone: map['customerPhone'],
    notes: map['notes'],
    createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'userId': userId, 'routerId': routerId, 'type': type,
    'profile': profile, 'quantity': quantity, 'unitPrice': unitPrice,
    'totalAmount': totalAmount, 'customerName': customerName,
    'customerPhone': customerPhone, 'notes': notes, 'createdAt': createdAt,
  };
}
