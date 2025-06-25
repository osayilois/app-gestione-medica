// import necessari
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/services/prescription_service.dart';
import 'package:printing/printing.dart'; // per preview
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class AdminPrescriptionPage extends StatefulWidget {
  const AdminPrescriptionPage({super.key});
  @override
  State<AdminPrescriptionPage> createState() => _AdminPrescriptionPageState();
}

class _AdminPrescriptionPageState extends State<AdminPrescriptionPage> {
  final _firestore = FirebaseFirestore.instance;
  final PrescriptionService _service = PrescriptionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Prescriptions',
          style: AppTextStyles.title2(color: Colors.black),
        ),
        backgroundColor: Colors.deepPurple.shade200,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('prescriptions')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No requests.', style: AppTextStyles.body()),
            );
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final requestId = doc.id;
              final status = data['status'] as String? ?? '';
              final patientId = data['patientId'] as String? ?? '';
              final name = data['name'] as String? ?? '';
              final type = data['type'] as String? ?? '';
              final doctorName = data['doctorName'] as String? ?? '';
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final pdfUrl = data['pdfUrl'] as String?;
              final barcodeData = data['barcodeData'] as String?;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type: $type',
                        style: AppTextStyles.subtitle(color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text('Name: $name', style: AppTextStyles.body()),
                      const SizedBox(height: 4),
                      Text(
                        'Patient ID: $patientId',
                        style: AppTextStyles.body().copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: $status',
                        style: AppTextStyles.body().copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              status == 'approved'
                                  ? Colors.green
                                  : status == 'declined'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Medical Practitioner: $doctorName',
                        style: AppTextStyles.body().copyWith(fontSize: 12),
                      ),
                      Text(
                        'Date: ${timestamp.toString().substring(0, 16)}',
                        style: AppTextStyles.body().copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      if (status == 'pending') ...[
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check, size: 18),
                              label: Text(
                                'Approve',
                                style: AppTextStyles.buttons(
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                // Chiamata a service
                                try {
                                  await _service.approveRequestAndGeneratePdf(
                                    requestId: requestId,
                                  );
                                  // Dopo aver generato e salvato, recupera il PDF per preview:
                                  final docAfter =
                                      await _firestore
                                          .collection('prescriptions')
                                          .doc(requestId)
                                          .get();
                                  final pdfUrl2 =
                                      (docAfter.data()?['pdfUrl'] as String?) ??
                                      '';
                                  if (pdfUrl2.isNotEmpty) {
                                    // Scarica bytes e mostra preview
                                    final pdfBytes = await _downloadPdfBytes(
                                      pdfUrl2,
                                    );
                                    if (pdfBytes != null) {
                                      _showPdfPreview(pdfBytes);
                                    }
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Errore approvazione: $e'),
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.close, size: 18),
                              label: Text(
                                'Decline',
                                style: AppTextStyles.buttons(
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                await _service.declineRequest(
                                  requestId: requestId,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Request declined'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ] else if (status == 'approved' && pdfUrl != null) ...[
                        // Se già approvato, bottone per preview
                        ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf),
                          label: Text(
                            'Preview PDF',
                            style: AppTextStyles.buttons(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade300,
                          ),
                          onPressed: () async {
                            final pdfBytes = await _downloadPdfBytes(pdfUrl);
                            if (pdfBytes != null) {
                              _showPdfPreview(pdfBytes);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<Uint8List?> _downloadPdfBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('Errore HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Errore download PDF: $e');
      return null;
    }
  }

  void _showPdfPreview(Uint8List pdfBytes) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            child: SizedBox(
              width: double.infinity,
              height: 500,
              child: PdfPreview(
                // dal package printing
                build: (format) => pdfBytes,
              ),
            ),
          ),
    );
  }
}
