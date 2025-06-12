import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setData(String path, Map<String, dynamic> data) async {
    await _db.doc(path).set(data);
  }

  Future<void> updateData(String path, Map<String, dynamic> data) async {
    await _db.doc(path).update(data);
  }

  Future<void> deleteData(String path) async {
    await _db.doc(path).delete();
  }

  Stream<T> documentStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
  }) {
    return _db.doc(path).snapshots().map((snap) {
      final d = snap.data();
      if (d == null) throw StateError('Document $path not found');
      return builder(d, snap.id);
    });
  }

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T a, T b)? sort,
  }) {
    Query query = _db.collection(path);
    if (queryBuilder != null) query = queryBuilder(query);
    return query.snapshots().map((snapshot) {
      final list =
          snapshot.docs
              .map((doc) => builder(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
      if (sort != null) {
        list.sort(sort);
      }
      return list;
    });
  }
}
