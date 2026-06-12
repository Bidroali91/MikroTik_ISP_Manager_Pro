import '../../domain/entities/hotspot_user_entity.dart';
import '../../domain/repositories/hotspot_repository.dart';

class HotspotRepositoryImpl implements HotspotRepository {
  @override
  Future<List<HotspotUserEntity>> getUsers(String routerId) async {
    return [];
  }

  @override
  Future<void> addUser(String routerId, String name, String password, String profile) async {
  }

  @override
  Future<void> removeUser(String routerId, String id) async {
  }

  @override
  Future<void> enableUser(String routerId, String id) async {
  }

  @override
  Future<void> disableUser(String routerId, String id) async {
  }

  @override
  Future<int> getActiveUserCount(String routerId) async {
    return 0;
  }
}
