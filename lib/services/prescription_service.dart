import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare_app/pages/prescriptions/prescription_request.dart';
import 'package:medicare_app/services/firestore_service.dart';
import 'package:medicare_app/util/pdf_generator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class PrescriptionService {
  final FirestoreService _fs = FirestoreService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
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

  Future<Uint8List?> downloadPdfBytes(String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      final data = await ref.getData();
      return data;
    } catch (e) {
      print('Errore nel download PDF: $e');
      return null;
    }
  }

  // ===============================
  // 👩‍⚕️ INTERFACCIA ADMIN
  // ===============================

  /// 🔄 Stream per vedere tutte le richieste
  /* Stream<List<Map<String, dynamic>>> getAllRequestsStream() {
    return _firestore
        .collection('prescriptions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'type': data['type'],
              'name': data['name'],
              'message': data['message'],
              'status': data['status'],
              'patientId': data['patientId'],
              'patientName': data['patientName'],
              'timestamp': data['timestamp'],
              'doctorName': data['doctorName'],
            };
          }).toList();
        });
  } */

  /* /// 🟢 Cambia stato (usato dall'admin)
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    await _firestore.collection('prescriptions').doc(requestId).update({
      'status': newStatus,
    });

    // 🔁 Sincronizza anche nel sotto-documento utente
    final snap =
        await _firestore.collection('prescriptions').doc(requestId).get();
    final patientId = snap.data()?['patientId'];
    if (patientId != null) {
      await _firestore
          .collection('users')
          .doc(patientId)
          .collection('prescriptions')
          .doc(requestId)
          .update({'status': newStatus});
    }
  } */

  /// Admin: approva, genera PDF+barcode, salva in Storage e Firestore.
  Future<void> approveRequestAndGeneratePdf({required String requestId}) async {
    // 1) recupera il documento in /prescriptions/{requestId}
    final docRef = _firestore.collection('prescriptions').doc(requestId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) throw Exception("Request $requestId non trovato");

    final data = docSnap.data()!;
    final patientId = data['patientId'] as String?;
    final patientName = data['patientName'] as String? ?? 'Unknown';
    final type = data['type'] as String? ?? '';
    final name = data['name'] as String? ?? '';
    final message = data['message'] as String? ?? '';
    // Prepara i campi per PDF: ad es. medicine=name, dosage=message o dettagli...
    final medicineOrVisit = name;
    final dosageOrDetails = message.isNotEmpty ? message : 'N/A';

    // 2) Genera PDF + barcode
    final pdfResult = await generatePrescriptionPdfData(
      patientName: patientName,
      medicineOrVisit: medicineOrVisit,
      dosageOrDetails: dosageOrDetails,
    );

    // 3) Carica PDF su Firebase Storage
    final storageRef = _storage
        .ref()
        .child('prescriptions_pdf')
        .child('$requestId.pdf');
    // Metadata: contentType
    final metadata = SettableMetadata(contentType: 'application/pdf');
    await storageRef.putData(pdfResult.data, metadata);
    final pdfUrl = await storageRef.getDownloadURL();

    // 4) Aggiorna Firestore:
    // - in /prescriptions/{requestId}
    await docRef.update({
      'status': 'approved',
      'pdfUrl': pdfUrl,
      'barcodeData': pdfResult.barcodeData,
    });
    // - nel sotto-documento utente: /users/{patientId}/prescriptions/{requestId}
    if (patientId != null && patientId.isNotEmpty) {
      final userDocRef = _firestore
          .collection('users')
          .doc(patientId)
          .collection('prescriptions')
          .doc(requestId);
      await userDocRef.update({
        'status': 'approved',
        'pdfUrl': pdfUrl,
        'barcodeData': pdfResult.barcodeData,
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
