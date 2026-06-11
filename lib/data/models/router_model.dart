class RouterModel {
  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  final String password;
  final bool useTls;
  final bool isConnected;
  final String? identity;
  final String? version;
  final String? model;
  final String? uptime;
  final double? cpuLoad;
  final double? temperature;
  final DateTime createdAt;
  final String? ownerId;

  RouterModel({
    required this.id, required this.name, required this.host,
    this.port = 8728, required this.username, required this.password,
    this.useTls = false, this.isConnected = false, this.identity,
    this.version, this.model, this.uptime, this.cpuLoad,
    this.temperature, DateTime? createdAt, this.ownerId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RouterModel.fromMap(String id, Map<String, dynamic> map) => RouterModel(
    id: id, name: map['name'] ?? '', host: map['host'] ?? '',
    port: map['port'] ?? 8728, username: map['username'] ?? '',
    password: map['password'] ?? '', useTls: map['useTls'] ?? false,
    isConnected: map['isConnected'] ?? false, identity: map['identity'],
    version: map['version'], model: map['model'], uptime: map['uptime'],
    cpuLoad: (map['cpuLoad'] as num?)?.toDouble(),
    temperature: (map['temperature'] as num?)?.toDouble(),
    createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    ownerId: map['ownerId'],
  );

  Map<String, dynamic> toMap() => {
    'name': name, 'host': host, 'port': port, 'username': username,
    'password': password, 'useTls': useTls, 'isConnected': isConnected,
    'identity': identity, 'version': version, 'model': model,
    'uptime': uptime, 'cpuLoad': cpuLoad, 'temperature': temperature,
    'createdAt': createdAt, 'ownerId': ownerId,
  };
}
