import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare_app/pages/prescriptions/prescription_request.dart';
import 'package:medicare_app/services/firestore_service.dart';

class PrescriptionService {
  final FirestoreService _fs = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userCollectionPath(String uid) => 'users/$uid/prescriptions';

  /// 🔄 Stream delle richieste del paziente attualmente loggato
  Stream<List<PrescriptionRequest>> watchRequestsForUser() {
    final uid = _auth.currentUser!.uid;
    return _fs.collectionStream<PrescriptionRequest>(
      path: _userCollectionPath(uid),
      builder: (data, id) => PrescriptionRequest.fromMap(id, data),
      queryBuilder: (q) => q.orderBy('timestamp', descending: true),
    );
  }

  /// 📤 Invio di una nuova richiesta
  Future<void> sendRequest({
    required PrescriptionType type,
    required String name,
    String? description,
    required String doctorName,
  }) async {
    final uid = _auth.currentUser!.uid;
    final coll = _firestore
        .collection('users')
        .doc(uid)
        .collection('prescriptions');
    final docRef = coll.doc(); // ID generato automaticamente
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

    // 🔁 Per accesso admin: salviamo anche in /prescriptions
    await _firestore.collection('prescriptions').doc(docRef.id).set({
      'id': docRef.id,
      'type': type.toString().split('.').last,
      'name': name,
      'message': description,
      'status': 'pending',
      'timestamp': now,
      'patientId': uid,
      'patientName': _auth.currentUser?.displayName ?? 'Unknown',
      'doctorName': doctorName,
    });
  }

  /// ✅ Update dello stato da parte del paziente (opzionale)
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

  /// Admin: approva e genera barcode univoco
  Future<void> approveRequestAndGenerateBarcode({
    required String requestId,
  }) async {
    final docRef = _firestore.collection('prescriptions').doc(requestId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) throw Exception("Request $requestId non trovata");

    final data = docSnap.data()!;
    final patientId = data['patientId'] as String?;
    final barcodeData = 'RX-${DateTime.now().millisecondsSinceEpoch}';

    // Aggiorna Firestore: barcode + status
    await docRef.update({'status': 'approved', 'barcodeData': barcodeData});

    if (patientId != null && patientId.isNotEmpty) {
      final userDocRef = _firestore
          .collection('users')
          .doc(patientId)
          .collection('prescriptions')
          .doc(requestId);
      await userDocRef.update({
        'status': 'approved',
        'barcodeData': barcodeData,
      });
    }
  }

  /// Admin: rifiuta richiesta
  Future<void> declineRequest({required String requestId}) async {
    final docRef = _firestore.collection('prescriptions').doc(requestId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) return;
    final data = docSnap.data()!;
    final patientId = data['patientId'] as String?;
    await docRef.update({'status': 'declined'});
    if (patientId != null && patientId.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(patientId)
          .collection('prescriptions')
          .doc(requestId)
          .update({'status': 'declined'});
    }
  }
}
