class FirestorePaths {
  // Collezione principale delle prescrizioni. Scegli se usare /users/{uid}/prescriptions
  // o una collection top-level “prescriptions” con campo patientId. Nel nostro esempio useremo sotto utente:
  static String userPrescriptions(String userId) =>
      'users/$userId/prescriptions';
  static String userPrescription(String userId, String prescriptionId) =>
      'users/$userId/prescriptions/$prescriptionId';
}
