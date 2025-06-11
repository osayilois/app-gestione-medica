// lib/pages/prescriptions_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:intl/intl.dart';

// Include qui il modello PrescriptionRequest e enum definiti prima:
enum PrescriptionStatus { pending, approved, rejected }

enum PrescriptionType { medicine, visit }

class PrescriptionRequest {
  final String id;
  final PrescriptionType type;
  final String name;
  final String? description;
  final PrescriptionStatus status;
  final DateTime timestamp;
  final String doctorId;
  final String? doctorName;

  PrescriptionRequest({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    required this.status,
    required this.timestamp,
    required this.doctorId,
    this.doctorName,
  });

  factory PrescriptionRequest.fromMap(String id, Map<String, dynamic> data) {
    PrescriptionType type = PrescriptionType.values.firstWhere(
      (e) => e.toString() == 'PrescriptionType.' + (data['type'] ?? 'medicine'),
      orElse: () => PrescriptionType.medicine,
    );
    PrescriptionStatus status = PrescriptionStatus.values.firstWhere(
      (e) =>
          e.toString() == 'PrescriptionStatus.' + (data['status'] ?? 'pending'),
      orElse: () => PrescriptionStatus.pending,
    );
    Timestamp? ts = data['timestamp'] as Timestamp?;
    return PrescriptionRequest(
      id: id,
      type: type,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      status: status,
      timestamp: ts != null ? ts.toDate() : DateTime.now(),
      doctorId: data['doctorId'] as String? ?? '',
      doctorName: data['doctorName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString().split('.').last,
      'name': name,
      'description': description,
      'status': status.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'doctorId': doctorId,
      'doctorName': doctorName,
    };
  }
}

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({Key? key}) : super(key: key);

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  int _selectedSection = 0; // 0 = richieste, 1 = nuova richiesta

  String? _medicoBaseId;
  String? _medicoBaseName;
  bool _loadingDoctor = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorBase();
  }

  Future<void> _loadDoctorBase() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    setState(() {
      _medicoBaseId = data?['medicoBaseId'] as String?;
      _medicoBaseName = data?['medicoBaseName'] as String?;
      _loadingDoctor = false;
    });
  }

  Future<void> sendPrescriptionRequest({
    required PrescriptionType type,
    required String name,
    String? description,
    required String doctorId,
    required String doctorName,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef =
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('prescriptions')
            .doc();
    final now = DateTime.now();
    final request = PrescriptionRequest(
      id: docRef.id,
      type: type,
      name: name,
      description: description,
      status: PrescriptionStatus.pending,
      timestamp: now,
      doctorId: doctorId,
      doctorName: doctorName,
    );
    await docRef.set(request.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Toggle alto tra richieste / nuova richiesta
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: List.generate(2, (index) {
                final labels = ['My Requests', 'New Request'];
                final isSel = index == _selectedSection;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSection = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color:
                            isSel
                                ? Colors.deepPurple.shade300
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          labels[index],
                          style: AppTextStyles.buttons(
                            color: isSel ? Colors.white : Colors.grey[700]!,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          // Contenuto
          Expanded(
            child:
                _selectedSection == 0
                    ? StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('prescriptions')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final docs = snap.data?.docs ?? [];
                        final requests =
                            docs.map((doc) {
                              return PrescriptionRequest.fromMap(
                                doc.id,
                                doc.data() as Map<String, dynamic>,
                              );
                            }).toList();
                        return _RequestsListView(allRequests: requests);
                      },
                    )
                    : _loadingDoctor
                    ? const Center(child: CircularProgressIndicator())
                    : (_medicoBaseId == null || _medicoBaseName == null)
                    ? Center(
                      child: Text(
                        'You do not have a medical practitioner.',
                        style: AppTextStyles.body(color: Colors.black),
                      ),
                    )
                    : _NewRequestForm(
                      doctorId: _medicoBaseId!,
                      doctorName: _medicoBaseName!,
                    ),
          ),
        ],
      ),
    );
  }
}

// Widget per la lista delle richieste, con toggle interno per stato
class _RequestsListView extends StatefulWidget {
  final List<PrescriptionRequest> allRequests;
  const _RequestsListView({required this.allRequests, Key? key})
    : super(key: key);

  @override
  State<_RequestsListView> createState() => _RequestsListViewState();
}

class _RequestsListViewState extends State<_RequestsListView> {
  int _selectedIndex = 0; // 0: pending, 1: approved, 2: rejected

  @override
  Widget build(BuildContext context) {
    // Filtra in base a _selectedIndex
    PrescriptionStatus statusFilter;
    switch (_selectedIndex) {
      case 0:
        statusFilter = PrescriptionStatus.pending;
        break;
      case 1:
        statusFilter = PrescriptionStatus.approved;
        break;
      case 2:
      default:
        statusFilter = PrescriptionStatus.rejected;
    }
    final filtered =
        widget.allRequests.where((r) => r.status == statusFilter).toList();

    return Column(
      children: [
        // Toggle pill per stato
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: List.generate(3, (index) {
              final labels = ['Pending', 'Approved', 'Rejected'];
              final isSel = index == _selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          isSel
                              ? Colors.deepPurple.shade300
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        labels[index],
                        style: AppTextStyles.buttons(
                          color: isSel ? Colors.white : Colors.grey[700]!,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        // Lista filtrata
        Expanded(
          child:
              filtered.isEmpty
                  ? Center(
                    child: Text(
                      'No requests.',
                      style: AppTextStyles.body(color: Colors.black),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final req = filtered[i];
                      return _buildRequestCard(req);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(PrescriptionRequest req) {
    Color statusColor;
    String statusText;
    switch (req.status) {
      case PrescriptionStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case PrescriptionStatus.approved:
        statusColor = Colors.green;
        statusText = 'Approved';
        break;
      case PrescriptionStatus.rejected:
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Riga superiore: Icona + tipo + data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      req.type == PrescriptionType.medicine
                          ? Icons.medical_services
                          : Icons.calendar_today,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      req.type == PrescriptionType.medicine
                          ? 'Medicinale'
                          : 'Visita',
                      style: AppTextStyles.subtitle(color: Colors.black),
                    ),
                  ],
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(req.timestamp),
                  style: AppTextStyles.body(color: Colors.grey[700]!),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(req.name, style: AppTextStyles.title2(color: Colors.black)),
            if (req.description != null && req.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                req.description!,
                style: AppTextStyles.body(color: Colors.black),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: AppTextStyles.body(color: Colors.black),
                    ),
                  ],
                ),
                if (req.status == PrescriptionStatus.approved) ...[
                  ElevatedButton(
                    onPressed: () {
                      // Apri prescrizione: genera o mostra PDF / barcode
                      _showPrescriptionDetail(context, req);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Open prescription',
                      style: AppTextStyles.buttons(color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPrescriptionDetail(BuildContext context, PrescriptionRequest req) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              'Prescription for ${req.name}',
              style: AppTextStyles.title2(color: Colors.black),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 100,
                  width: 200,
                  color: Colors.grey[300],
                  child: Center(child: Text('BARCODE PLACEHOLDER')),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Qui potresti integrare un PDF viewer
                  },
                  icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: Text(
                    'View PDF',
                    style: AppTextStyles.buttons(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Chiudi'),
              ),
            ],
          ),
    );
  }
}

// Form nuova richiesta
class _NewRequestForm extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  const _NewRequestForm({
    required this.doctorId,
    required this.doctorName,
    Key? key,
  }) : super(key: key);

  @override
  State<_NewRequestForm> createState() => _NewRequestFormState();
}

class _NewRequestFormState extends State<_NewRequestForm> {
  PrescriptionType _type = PrescriptionType.medicine;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type of request',
              style: AppTextStyles.subtitle(color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap:
                        () => setState(() => _type = PrescriptionType.medicine),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            _type == PrescriptionType.medicine
                                ? Colors.deepPurple.shade300
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Medicine',
                          style: AppTextStyles.body(
                            color:
                                _type == PrescriptionType.medicine
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = PrescriptionType.visit),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            _type == PrescriptionType.visit
                                ? Colors.deepPurple.shade300
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Visit',
                          style: AppTextStyles.body(
                            color:
                                _type == PrescriptionType.visit
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText:
                    _type == PrescriptionType.medicine
                        ? 'Medicine name'
                        : 'Type of requested visit',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Campo richiesto';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Additional notes (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isSubmitting
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Send request',
                          style: AppTextStyles.buttons(color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final name = _nameController.text.trim();
      final desc = _descController.text.trim();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('prescriptions')
          .doc()
          .set(
            PrescriptionRequest(
              id: '', // temporaneo, Firestore genererà ID
              type: _type,
              name: name,
              description: desc.isEmpty ? null : desc,
              status: PrescriptionStatus.pending,
              timestamp: DateTime.now(),
              doctorId: widget.doctorId,
              doctorName: widget.doctorName,
            ).toMap(),
          );
      _nameController.clear();
      _descController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request sent!',
            style: AppTextStyles.body(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Errore durante l\'invio: $e',
            style: AppTextStyles.body(color: Colors.white),
          ),
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
