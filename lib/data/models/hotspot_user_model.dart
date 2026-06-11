class HotspotUserModel {
  final String id;
  final String routerId;
  final String name;
  final String password;
  final String profile;
  final String? comment;
  final bool disabled;
  final String? uptime;
  final int bytesIn;
  final int bytesOut;
  final String? limitUptime;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final double? price;

  HotspotUserModel({
    required this.id, required this.routerId, required this.name,
    required this.password, this.profile = 'default', this.comment,
    this.disabled = false, this.uptime, this.bytesIn = 0, this.bytesOut = 0,
    this.limitUptime, this.expiresAt, DateTime? createdAt, this.price,
  }) : createdAt = createdAt ?? DateTime.now();

  factory HotspotUserModel.fromMap(String id, Map<String, dynamic> map) => HotspotUserModel(
    id: id, routerId: map['routerId'] ?? '', name: map['name'] ?? '',
    password: map['password'] ?? '', profile: map['profile'] ?? 'default',
    comment: map['comment'], disabled: map['disabled'] ?? false,
    uptime: map['uptime'], bytesIn: map['bytesIn'] ?? 0, bytesOut: map['bytesOut'] ?? 0,
    limitUptime: map['limitUptime'],
    expiresAt: (map['expiresAt'] as dynamic)?.toDate(),
    createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    price: (map['price'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'routerId': routerId, 'name': name, 'password': password,
    'profile': profile, 'comment': comment, 'disabled': disabled,
    'uptime': uptime, 'bytesIn': bytesIn, 'bytesOut': bytesOut,
    'limitUptime': limitUptime, 'expiresAt': expiresAt,
    'createdAt': createdAt, 'price': price,
  };
}
