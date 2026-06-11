import '../entities/router_entity.dart';

abstract class RouterRepository {
  Future<List<RouterEntity>> getRouters(String userId);
  Future<void> addRouter(RouterEntity router);
  Future<void> updateRouter(RouterEntity router);
  Future<void> deleteRouter(String id);
  Future<bool> testConnection(String host, int port, String username, String password);
}
