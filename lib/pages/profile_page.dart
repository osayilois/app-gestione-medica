// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare_app/theme/text_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool isEditing = false;

  // controllers per i campi editabili
  final _codiceFiscaleController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _medicoBaseController = TextEditingController();

  // dati per la view non-editabile
  String? codiceFiscale;
  String? telefono;
  String? medicoBase;

  // dati medicalCard
  DateTime? birthDate;
  String? bloodType;
  String? allergies;
  String? conditions;
  String? therapy;

  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (user == null) return;
    final doc = await firestore.collection('users').doc(user!.uid).get();
    final data = doc.data() ?? {};

    setState(() {
      // general info
      codiceFiscale = data['codiceFiscale'];
      telefono = data['telefono'];
      medicoBase = data['medicoBase'];
      _codiceFiscaleController.text = codiceFiscale ?? '';
      _telefonoController.text = telefono ?? '';
      _medicoBaseController.text = medicoBase ?? '';

      // medicalCard
      final mc = data['medicalCard'] as Map<String, dynamic>?;
      if (mc != null) {
        birthDate =
            mc['birthDate'] != null ? DateTime.parse(mc['birthDate']) : null;
        bloodType = mc['bloodType'];
        allergies = mc['allergies'];
        conditions = mc['conditions'];
        therapy = mc['therapy'];
      }
    });
  }

  Future<void> _saveGeneralInfo() async {
    if (!_formKey.currentState!.validate()) return;
    if (user == null) return;

    await firestore.collection('users').doc(user!.uid).set({
      'codiceFiscale': _codiceFiscaleController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'medicoBase': _medicoBaseController.text.trim(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Information saved successfully!')),
    );

    setState(() {
      isEditing = false;
      codiceFiscale = _codiceFiscaleController.text.trim();
      telefono = _telefonoController.text.trim();
      medicoBase = _medicoBaseController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nomeCompleto = user?.displayName ?? '';
    final email = user?.email ?? '';
    final nome = nomeCompleto.split(' ').first;
    final cognome =
        nomeCompleto.split(' ').length > 1 ? nomeCompleto.split(' ')[1] : '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTextStyles.title2(color: Colors.deepPurple),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isEditing ? Icons.close : Icons.edit,
              color: Colors.deepPurple,
            ),
            onPressed: () => setState(() => isEditing = !isEditing),
            tooltip: isEditing ? 'Cancel' : 'Edit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            const SizedBox(height: 20),

            // --- General Information ---
            Text(
              'General Information',
              style: AppTextStyles.subtitle(
                color: Colors.deepPurple,
              ).copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildInfoRow('Name', nome),
                    buildInfoRow('Surname', cognome),
                    buildInfoRow('Email', email),
                    const SizedBox(height: 12),

                    // campi editabili
                    if (!isEditing) ...[
                      if (codiceFiscale != null)
                        buildInfoRow('Fiscal Code', codiceFiscale!),
                      if (telefono != null)
                        buildInfoRow('Phone Number', telefono!),
                      if (medicoBase != null)
                        buildInfoRow('Medical Practitioner', medicoBase!),
                    ] else ...[
                      buildEditableField(
                        'Fiscal Code',
                        _codiceFiscaleController,
                      ),
                      buildEditableField(
                        'Phone Number',
                        _telefonoController,
                        keyboard: TextInputType.phone,
                      ),
                      buildEditableField(
                        'Medical Practitioner',
                        _medicoBaseController,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveGeneralInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Save',
                  style: AppTextStyles.buttons(color: Colors.white),
                ),
              ),
            ],

            const SizedBox(height: 30),

            // --- Medical Information ---
            Text(
              'Medical Information',
              style: AppTextStyles.subtitle(
                color: Colors.deepPurple,
              ).copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (birthDate != null)
                    buildInfoRow(
                      'Date of Birth',
                      '${birthDate!.day.toString().padLeft(2, '0')}/${birthDate!.month.toString().padLeft(2, '0')}/${birthDate!.year}',
                    ),
                  if (bloodType != null) buildInfoRow('Blood Type', bloodType!),
                  if (allergies != null) buildInfoRow('Allergies', allergies!),
                  if (conditions != null)
                    buildInfoRow('Conditions', conditions!),
                  if (therapy != null) buildInfoRow('Therapy', therapy!),
                  if (birthDate == null &&
                      bloodType == null &&
                      allergies == null &&
                      conditions == null &&
                      therapy == null)
                    Text(
                      'No medical information yet.',
                      style: AppTextStyles.body(color: Colors.grey[600]!),
                    ),
                ],
              ),
            ),
          ], //children
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label: ', style: AppTextStyles.subtitle(color: Colors.black)),
          Flexible(
            child: Text(value, style: AppTextStyles.body(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget buildEditableField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        enabled: isEditing,
        style: AppTextStyles.body(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.body(color: Colors.grey[700]!),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.deepPurple, width: 1.5),
          ),
        ),
        validator: (value) {
          if (isEditing && (value == null || value.isEmpty)) {
            return 'Required field';
          }
          return null;
        },
      ),
    );
  }
}
