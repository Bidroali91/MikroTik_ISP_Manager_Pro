import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String username;
  final String password;
  final String profile;
  final String profileName;
  final int durationHours;
  final double price;
  final bool isUsed;
  final DateTime? usedAt;
  final String? usedByIp;
  final DateTime createdAt;
  final String? routerId;
  final String? printedBy;

  VoucherModel({
    required this.id,
    required this.username,
    required this.password,
    required this.profile,
    required this.profileName,
    required this.durationHours,
    required this.price,
    this.isUsed = false,
    this.usedAt,
    this.usedByIp,
    required this.createdAt,
    this.routerId,
    this.printedBy,
  });

  factory VoucherModel.fromMap(Map<String, dynamic> map) {
    return VoucherModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      profile: map['profile'] ?? '',
      profileName: map['profileName'] ?? '',
      durationHours: map['durationHours'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      isUsed: map['isUsed'] ?? false,
      usedAt: map['usedAt'] != null ? (map['usedAt'] as Timestamp).toDate() : null,
      usedByIp: map['usedByIp'],
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
      routerId: map['routerId'],
      printedBy: map['printedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'profile': profile,
      'profileName': profileName,
      'durationHours': durationHours,
      'price': price,
      'isUsed': isUsed,
      'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
      'usedByIp': usedByIp,
      'createdAt': Timestamp.fromDate(createdAt),
      'routerId': routerId,
      'printedBy': printedBy,
    };
  }

  VoucherModel copyWith({
    String? id,
    String? username,
    String? password,
    String? profile,
    String? profileName,
    int? durationHours,
    double? price,
    bool? isUsed,
    DateTime? usedAt,
    String? usedByIp,
    DateTime? createdAt,
    String? routerId,
    String? printedBy,
  }) {
    return VoucherModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      profile: profile ?? this.profile,
      profileName: profileName ?? this.profileName,
      durationHours: durationHours ?? this.durationHours,
      price: price ?? this.price,
      isUsed: isUsed ?? this.isUsed,
      usedAt: usedAt ?? this.usedAt,
      usedByIp: usedByIp ?? this.usedByIp,
      createdAt: createdAt ?? this.createdAt,
      routerId: routerId ?? this.routerId,
      printedBy: printedBy ?? this.printedBy,
    );
  }
}