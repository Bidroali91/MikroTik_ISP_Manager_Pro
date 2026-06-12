class PppoeUserModel {
  final String id;
  final String routerId;
  final String username;
  final String password;
  final String service;
  final String profile;
  final bool disabled;
  final String? remoteAddress;
  final String? uptime;
  final int bytesIn;
  final int bytesOut;
  final String? comment;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final double? price;

  PppoeUserModel({
    required this.id, required this.routerId, required this.username,
    required this.password, this.service = 'pppoe', this.profile = 'default',
    this.disabled = false, this.remoteAddress, this.uptime,
    this.bytesIn = 0, this.bytesOut = 0, this.comment,
    DateTime? createdAt, this.expiresAt, this.price,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PppoeUserModel.fromMap(String id, Map<String, dynamic> map) => PppoeUserModel(
    id: id, routerId: map['routerId'] ?? '', username: map['username'] ?? '',
    password: map['password'] ?? '', service: map['service'] ?? 'pppoe',
    profile: map['profile'] ?? 'default', disabled: map['disabled'] ?? false,
    remoteAddress: map['remoteAddress'], uptime: map['uptime'],
    bytesIn: map['bytesIn'] ?? 0, bytesOut: map['bytesOut'] ?? 0,
    comment: map['comment'],
    createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    expiresAt: (map['expiresAt'] as dynamic)?.toDate(),
    price: (map['price'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'routerId': routerId, 'username': username, 'password': password,
    'service': service, 'profile': profile, 'disabled': disabled,
    'remoteAddress': remoteAddress, 'uptime': uptime,
    'bytesIn': bytesIn, 'bytesOut': bytesOut, 'comment': comment,
    'createdAt': createdAt, 'expiresAt': expiresAt, 'price': price,
  };
}
