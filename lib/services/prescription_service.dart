import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare_app/models/prescription_request.dart';
import 'package:medicare_app/services/firestore_service.dart';

class PrescriptionService {
  final FirestoreService _fs = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _userCollectionPath(String uid) => 'users/$uid/prescriptions';

  Stream<List<PrescriptionRequest>> watchRequestsForUser() {
    final uid = _auth.currentUser!.uid;
    return _fs.collectionStream<PrescriptionRequest>(
      path: _userCollectionPath(uid),
      builder: (data, id) => PrescriptionRequest.fromMap(id, data),
      queryBuilder: (q) => q.orderBy('timestamp', descending: true),
      // opzionale sort: già ordinato via Firestore
    );
  }

  Future<void> sendRequest({
    required PrescriptionType type,
    required String name,
    String? description,
    required String doctorName,
  }) async {
    final uid = _auth.currentUser!.uid;
    final coll = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('prescriptions');
    final docRef = coll.doc(); // id generato
    final now = DateTime.now();
    final req = PrescriptionRequest(
      id: docRef.id,
      patientId: uid,
      type: type,
      name: name,
      description: description,
      status: PrescriptionStatus.pending,
      timestamp: now,
      doctorName: doctorName,
    );
    await docRef.set(req.toMap());
  }

  Future<void> updateStatus(
    String requestId,
    PrescriptionStatus newStatus,
  ) async {
    final uid = _auth.currentUser!.uid;
    final path = 'users/$uid/prescriptions/$requestId';
    await _fs.updateData(path, {
      'status': newStatus.toString().split('.').last,
    });
  }
}
