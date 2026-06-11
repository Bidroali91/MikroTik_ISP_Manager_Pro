import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/router_entity.dart';
import '../../domain/repositories/router_repository.dart';
import '../../core/constants/firebase_constants.dart';
import '../datasources/routeros/routeros_client.dart';
import '../models/router_model.dart';

class RouterRepositoryImpl implements RouterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<RouterEntity>> getRouters(String userId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.routersCollection)
        .where('ownerId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) {
      final m = RouterModel.fromMap(doc.id, doc.data());
      return RouterEntity(
        id: m.id, name: m.name, host: m.host, port: m.port,
        username: m.username, password: m.password,
        isConnected: m.isConnected, identity: m.identity,
      );
    }).toList();
  }

  @override
  Future<void> addRouter(RouterEntity router) async {
    final m = RouterModel(
      id: '', name: router.name, host: router.host, port: router.port,
      username: router.username, password: router.password,
      isConnected: router.isConnected, identity: router.identity,
    );
    await _firestore.collection(FirebaseConstants.routersCollection).add(m.toMap());
  }

  @override
  Future<void> updateRouter(RouterEntity router) async {
    final m = RouterModel(
      id: router.id, name: router.name, host: router.host, port: router.port,
      username: router.username, password: router.password,
      isConnected: router.isConnected, identity: router.identity,
    );
    await _firestore.collection(FirebaseConstants.routersCollection).doc(router.id).update(m.toMap());
  }

  @override
  Future<void> deleteRouter(String id) async {
    await _firestore.collection(FirebaseConstants.routersCollection).doc(id).delete();
  }

  @override
  Future<bool> testConnection(String host, int port, String username, String password) async {
    final client = RouterOSClient();
    try {
      await client.connect(host, port: port);
      return await client.login(username, password);
    } catch (_) {
      return false;
    } finally {
      client.disconnect();
    }
  }
}
