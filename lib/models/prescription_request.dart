import 'package:cloud_firestore/cloud_firestore.dart';

enum PrescriptionType { medicine, visit }

enum PrescriptionStatus { pending, approved, declined }

class PrescriptionRequest {
  final String id;
  final String patientId;
  final PrescriptionType type;
  final String name; // nome medicinale o descrizione visita
  final String? description;
  final PrescriptionStatus status;
  final DateTime timestamp;
  final String doctorName; // nome medico di base

  PrescriptionRequest({
    required this.id,
    required this.patientId,
    required this.type,
    required this.name,
    this.description,
    required this.status,
    required this.timestamp,
    required this.doctorName,
  });

  factory PrescriptionRequest.fromMap(String id, Map<String, dynamic> data) {
    // attenzione ai null: usiamo valori di default
    final typeStr = data['type'] as String? ?? 'medicine';
    final statusStr = data['status'] as String? ?? 'pending';
    PrescriptionType type = PrescriptionType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => PrescriptionType.medicine,
    );
    PrescriptionStatus status = PrescriptionStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusStr,
      orElse: () => PrescriptionStatus.pending,
    );
    return PrescriptionRequest(
      id: id,
      patientId: data['patientId'] as String? ?? '',
      type: type,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      status: status,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      doctorName: data['doctorName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'type': type.toString().split('.').last,
      'name': name,
      'description': description,
      'status': status.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'doctorName': doctorName,
    };
  }
}
