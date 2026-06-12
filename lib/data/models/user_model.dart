class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLogin;
  final List<String> routerIds;

  UserModel({
    required this.id, required this.email, required this.fullName,
    this.role = 'operator', this.isActive = true, this.phone,
    this.photoUrl, DateTime? createdAt, DateTime? lastLogin,
    this.routerIds = const [],
  }) : createdAt = createdAt ?? DateTime.now(), lastLogin = lastLogin ?? DateTime.now();

  factory UserModel.fromMap(String id, Map<String, dynamic> map) => UserModel(
    id: id, email: map['email'] ?? '', fullName: map['fullName'] ?? '',
    role: map['role'] ?? 'operator', isActive: map['isActive'] ?? true,
    phone: map['phone'], photoUrl: map['photoUrl'],
    createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    lastLogin: (map['lastLogin'] as dynamic)?.toDate() ?? DateTime.now(),
    routerIds: List<String>.from(map['routerIds'] ?? []),
  );

  Map<String, dynamic> toMap() => {
    'email': email, 'fullName': fullName, 'role': role,
    'isActive': isActive, 'phone': phone, 'photoUrl': photoUrl,
    'createdAt': createdAt, 'lastLogin': lastLogin, 'routerIds': routerIds,
  };
}
