import '../entities/hotspot_user_entity.dart';

abstract class HotspotRepository {
  Future<List<HotspotUserEntity>> getUsers(String routerId);
  Future<void> addUser(String routerId, String name, String password, String profile);
  Future<void> removeUser(String routerId, String id);
  Future<void> enableUser(String routerId, String id);
  Future<void> disableUser(String routerId, String id);
  Future<int> getActiveUserCount(String routerId);
}
