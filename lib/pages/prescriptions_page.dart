import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/models/prescription_request.dart';
import 'package:medicare_app/services/prescription_service.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicare_app/util/pdf_generator.dart';

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({Key? key}) : super(key: key);

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  final PrescriptionService _service = PrescriptionService();
  // 0: pending, 1: approved, 2: declined
  int _selectedIndex = 0;
  // per mostrare form o lista
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'All your prescription requests are shown here',
          style: AppTextStyles.buttons(color: Colors.grey[800]!),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Toggle “Le mie richieste” vs “Nuova richiesta”
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showForm = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            !_showForm
                                ? Colors.deepPurple.shade300
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'My requests',
                          style: AppTextStyles.body(
                            color: !_showForm ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showForm = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            _showForm
                                ? Colors.deepPurple.shade300
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'New request',
                          style: AppTextStyles.body(
                            color: _showForm ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _showForm
                    ? NewPrescriptionForm()
                    : StreamBuilder<List<PrescriptionRequest>>(
                      stream: _service.watchRequestsForUser(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snap.hasData) {
                          return Center(
                            child: Text(
                              'Loading error',
                              style: AppTextStyles.body(color: Colors.black),
                            ),
                          );
                        }
                        final all = snap.data!;
                        // Toggle interno per stato
                        return Column(
                          children: [
                            // filtro stato: pending/approved/declined
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: List.generate(3, (idx) {
                                    final labels = [
                                      'Pending',
                                      'Approved',
                                      'Declined',
                                    ];
                                    final isSel = idx == _selectedIndex;
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap:
                                            () => setState(
                                              () => _selectedIndex = idx,
                                            ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSel
                                                    ? Colors.deepPurple.shade300
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              labels[idx],
                                              style: AppTextStyles.body(
                                                color:
                                                    isSel
                                                        ? Colors.white
                                                        : Colors.grey[700]!,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Lista filtrata
                            Expanded(
                              child: Builder(
                                builder: (_) {
                                  PrescriptionStatus filter;
                                  switch (_selectedIndex) {
                                    case 1:
                                      filter = PrescriptionStatus.approved;
                                      break;
                                    case 2:
                                      filter = PrescriptionStatus.declined;
                                      break;
                                    case 0:
                                    default:
                                      filter = PrescriptionStatus.pending;
                                  }
                                  final filtered =
                                      all
                                          .where((r) => r.status == filter)
                                          .toList();
                                  if (filtered.isEmpty) {
                                    return Center(
                                      child: Text(
                                        'No requests.',
                                        style: AppTextStyles.body(
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemCount: filtered.length,
                                    itemBuilder:
                                        (ctx, i) =>
                                            _buildRequestCard(filtered[i]),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
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
      case PrescriptionStatus.declined:
      default:
        statusColor = Colors.red;
        statusText = 'Declined';
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Riga superiore: tipo + data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      req.type == PrescriptionType.medicine
                          ? FontAwesomeIcons.prescriptionBottleMedical
                          : FontAwesomeIcons.calendarWeek,
                      color: Colors.deepPurple.shade300,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      req.type == PrescriptionType.medicine
                          ? 'Medication'
                          : 'Visit',
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
                if (req.status == PrescriptionStatus.approved)
                  ElevatedButton(
                    onPressed: () {
                      // ad esempio mostra barcode o PDF
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text(
                                'Prescrizione: ${req.name}',
                                style: AppTextStyles.title2(
                                  color: Colors.black,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // qui un widget barcode o placeholder
                                  Container(
                                    height: 100,
                                    width: 200,
                                    color: Colors.grey[300],
                                    child: Center(child: Text('BARCODE')),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // apri PDF se disponibile: req.pdfUrl
                                    },
                                    icon: Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'View PDF',
                                      style: AppTextStyles.buttons(
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.deepPurple.shade300,
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
                                  child: Text('Close'),
                                ),
                              ],
                            ),
                      );
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
            ),
          ],
        ),
      ),
    );
  }
}

class NewPrescriptionForm extends StatefulWidget {
  const NewPrescriptionForm({Key? key}) : super(key: key);

  @override
  State<NewPrescriptionForm> createState() => _NewPrescriptionFormState();
}

class _NewPrescriptionFormState extends State<NewPrescriptionForm> {
  final _formKey = GlobalKey<FormState>();
  PrescriptionType _type = PrescriptionType.medicine;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSubmitting = false;
  final PrescriptionService _service = PrescriptionService();

  String _doctorName = ''; // verrà caricato dal profilo

  @override
  void initState() {
    super.initState();
    _loadDoctorName();
  }

  Future<void> _loadDoctorName() async {
    // Carica il nome del medico di base dal documento user (campo 'medicoBase')
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    setState(() {
      _doctorName = data?['medicoBase'] as String? ?? '';
    });
  }

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
                          'Medication',
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
                        ? 'Medication Name'
                        : 'Type of visit request',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required field';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Add note (optional)',
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
    if (_doctorName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Medical practitioner not updated',
            style: AppTextStyles.body(color: Colors.black),
          ),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await _service.sendRequest(
        type: _type,
        name: _nameController.text.trim(),
        description:
            _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
        doctorName: _doctorName,
      );
      // pulisci form e torna a lista
      _nameController.clear();
      _descController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request sent',
            style: AppTextStyles.body(color: Colors.white),
          ),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
      // resta sulla form o torna su “Le mie richieste”? Se vuoi tornare:
      // final parent = context.findAncestorStateOfType<_PrescriptionsPageState>();
      // parent?._showForm = false;
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error while sending",
            style: AppTextStyles.body(color: Colors.black),
          ),
        ),
      );
    }
  }
}
