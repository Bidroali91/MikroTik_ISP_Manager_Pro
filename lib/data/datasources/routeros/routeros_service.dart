import 'routeros_client.dart';
import 'hotspot_api.dart';
import 'pppoe_api.dart';
import 'system_api.dart';

class RouterOSService {
  final RouterOSClient client;
  late final HotspotApi hotspot;
  late final PppoeApi pppoe;
  late final SystemApi system;

  RouterOSService(this.client) {
    hotspot = HotspotApi(client);
    pppoe = PppoeApi(client);
    system = SystemApi(client);
  }

  static Future<RouterOSService> connect(String host, int port, String username, String password) async {
    final client = RouterOSClient();
    await client.connect(host, port: port);
    final loggedIn = await client.login(username, password);
    if (!loggedIn) {
      client.disconnect();
      throw Exception('RouterOS login failed');
    }
    return RouterOSService(client);
  }

  void disconnect() => client.disconnect();

  bool get isConnected => client.isConnected;
}
