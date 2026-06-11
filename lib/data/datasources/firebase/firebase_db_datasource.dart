import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDbDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;

  Future<void> setDocument(String collection, String id, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(id).set(data);
  }

  Future<Map<String, dynamic>?> getDocument(String collection, String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    final snapshot = await _firestore.collection(collection).get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  Future<List<Map<String, dynamic>>> queryCollection(String collection, String field, dynamic value) async {
    final snapshot = await _firestore.collection(collection).where(field, isEqualTo: value).get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  Future<void> deleteDocument(String collection, String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  Future<void> setRealtimeData(String path, Map<String, dynamic> data) async {
    await _rtdb.ref(path).set(data);
  }

  Stream<DatabaseEvent> getRealtimeStream(String path) {
    return _rtdb.ref(path).onValue;
  }
}
