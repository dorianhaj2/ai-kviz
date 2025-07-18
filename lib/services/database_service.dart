import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> create({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection(path).doc().set(data);
  }

  Future<QuerySnapshot?> read({required String path}) async {
    final QuerySnapshot snapshot = await _db.collection(path).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot;
    } else {
      return null;
    }
  }

  Future<void> update({
    required String path,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection(path).doc(id).update(data);
  }

  Future<void> delete({required String path, required String user}) async {
    await _db.collection(path).doc(user).delete();
  }
}
