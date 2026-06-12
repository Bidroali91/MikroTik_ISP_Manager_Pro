class RouterEntity {
  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  final String password;
  final bool isConnected;
  final String? identity;

  const RouterEntity({
    required this.id, required this.name, required this.host,
    this.port = 8728, required this.username, required this.password,
    this.isConnected = false, this.identity,
  });
}
