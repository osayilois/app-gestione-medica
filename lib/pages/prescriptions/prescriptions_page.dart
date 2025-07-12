// Lib: lib/pages/presciptions/prescription_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/pages/prescriptions/prescription_request.dart';
import 'package:medicare_app/services/prescription_service.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicare_app/widgets/prescription_detail_dialog.dart';

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({Key? key}) : super(key: key);

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  final PrescriptionService _service = PrescriptionService();
  bool _showForm = false;

  void _toggleView(bool showForm) {
    setState(() {
      _showForm = showForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _showForm ? 'New Prescription Request' : 'Your Prescription Requests',
          style: AppTextStyles.title2(color: Colors.grey[800]!),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ToggleSwitcher(showForm: _showForm, onToggle: _toggleView),
          ),
          Expanded(
            child:
                _showForm
                    ? NewPrescriptionForm(onSubmitted: () => _toggleView(false))
                    : RequestsView(service: _service),
          ),
        ],
      ),
    );
  }
}

// Widget per togglare tra lista richieste e form
class ToggleSwitcher extends StatelessWidget {
  final bool showForm;
  final ValueChanged<bool> onToggle;
  const ToggleSwitcher({
    Key? key,
    required this.showForm,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onToggle(false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    !showForm ? Colors.deepPurple.shade300 : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'My requests',
                  style: AppTextStyles.body(
                    color: !showForm ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => onToggle(true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: showForm ? Colors.deepPurple.shade300 : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'New request',
                  style: AppTextStyles.body(
                    color: showForm ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Vista lista richieste con filtro
class RequestsView extends StatefulWidget {
  final PrescriptionService service;
  const RequestsView({Key? key, required this.service}) : super(key: key);

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PrescriptionRequest>>(
      stream: widget.service.watchRequestsForUser(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StatusFilterTabs(
                selectedIndex: _selectedIndex,
                onTap: (idx) => setState(() => _selectedIndex = idx),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildFilteredList(all)),
          ],
        );
      },
    );
  }

  Widget _buildFilteredList(List<PrescriptionRequest> all) {
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
    final filtered = all.where((r) => r.status == filter).toList();
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No requests.',
          style: AppTextStyles.body(color: Colors.black),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => PrescriptionRequestCard(request: filtered[i]),
    );
  }
}

// Tab per filtro stato
class StatusFilterTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const StatusFilterTabs({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labels = ['Pending', 'Approved', 'Declined'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(3, (idx) {
          final isSel = idx == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(idx),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color:
                      isSel ? Colors.deepPurple.shade300 : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    labels[idx],
                    style: AppTextStyles.body(
                      color: isSel ? Colors.white : Colors.grey[700]!,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Card per singola richiesta
class PrescriptionRequestCard extends StatelessWidget {
  final PrescriptionRequest request;
  const PrescriptionRequestCard({Key? key, required this.request})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = _colorForStatus(request.status);
    final statusText = _textForStatus(request.status);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      request.type == PrescriptionType.medicine
                          ? FontAwesomeIcons.prescriptionBottleMedical
                          : FontAwesomeIcons.calendarWeek,
                      color: Colors.deepPurple.shade300,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      request.type == PrescriptionType.medicine
                          ? 'Medication'
                          : 'Visit',
                      style: AppTextStyles.subtitle(color: Colors.black),
                    ),
                  ],
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(request.timestamp),
                  style: AppTextStyles.body(color: Colors.grey[700]!),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.name,
              style: AppTextStyles.title2(color: Colors.black),
            ),
            if (request.description != null &&
                request.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                request.description!,
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
                if (request.status == PrescriptionStatus.approved)
                  ElevatedButton(
                    onPressed: () {
                      /* // Mostra dialog di mockup: grafica aperta prescrizione
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text(
                                'Prescription: ${request.name}',
                                style: AppTextStyles.title2(
                                  color: Colors.black,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 100,
                                    width: 200,
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Text(
                                        'BARCODE PLACEHOLDER',
                                        style: AppTextStyles.body(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Al momento non integrato: mostra messaggio o future implementazione
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'PDF feature not available yet',
                                            style: AppTextStyles.body(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
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
                                  child: Text(
                                    'Close',
                                    style: AppTextStyles.buttons(
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      ); */

                      // QUI VERRA MESSO IL METODO CHE VISUALIZZA IL BARCODE + PDF
                      showDialog(
                        context: context,
                        builder:
                            (_) => PrescriptionDetailDialog(request: request),
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

  Color _colorForStatus(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.pending:
        return Colors.orange;
      case PrescriptionStatus.approved:
        return Colors.green;
      case PrescriptionStatus.declined:
      default:
        return Colors.red;
    }
  }

  String _textForStatus(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.pending:
        return 'Pending';
      case PrescriptionStatus.approved:
        return 'Approved';
      case PrescriptionStatus.declined:
      default:
        return 'Declined';
    }
  }
}

// Form per nuova richiesta
class NewPrescriptionForm extends StatefulWidget {
  final VoidCallback? onSubmitted;
  const NewPrescriptionForm({Key? key, this.onSubmitted}) : super(key: key);

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
  String _doctorName = '';

  @override
  void initState() {
    super.initState();
    _loadDoctorName();
  }

  Future<void> _loadDoctorName() async {
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
                  child: ChoiceOption(
                    label: 'Medication',
                    selected: _type == PrescriptionType.medicine,
                    onTap:
                        () => setState(() => _type = PrescriptionType.medicine),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceOption(
                    label: 'Visit',
                    selected: _type == PrescriptionType.visit,
                    onTap: () => setState(() => _type = PrescriptionType.visit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              style: AppTextStyles.subtitle(color: Colors.black),
              decoration: InputDecoration(
                labelText:
                    _type == PrescriptionType.medicine
                        ? 'Medication Name'
                        : 'Type of visit request',
                labelStyle: AppTextStyles.body(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required field' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              style: AppTextStyles.subtitle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Add note (optional)',
                labelStyle: AppTextStyles.body(color: Colors.grey.shade600),
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
            style: AppTextStyles.body(color: Colors.white),
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
      widget.onSubmitted?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error while sending',
            style: AppTextStyles.body(color: Colors.black),
          ),
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

// Widget per opzione scelta tipo richiesta
class ChoiceOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const ChoiceOption({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple.shade300 : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body(
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
