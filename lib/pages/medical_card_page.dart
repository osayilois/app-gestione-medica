// lib/pages/medical_card_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MedicalCardPage extends StatefulWidget {
  const MedicalCardPage({super.key});

  @override
  State<MedicalCardPage> createState() => _MedicalCardPageState();
}

class _MedicalCardPageState extends State<MedicalCardPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _birth;
  String? _bloodType;
  final _allergies = TextEditingController();
  final _conditions = TextEditingController();
  final _therapy = TextEditingController();

  final _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final mc = doc.data()?['medicalCard'] as Map<String, dynamic>?;
      if (mc != null) {
        setState(() {
          _birth =
              mc['birthDate'] != null ? DateTime.parse(mc['birthDate']) : null;
          _bloodType = mc['bloodType'];
          _allergies.text = mc['allergies'] ?? '';
          _conditions.text = mc['conditions'] ?? '';
          _therapy.text = mc['therapy'] ?? '';
        });
      }
    } catch (e) {
      // Se fallisce, logga e continua (non blocchi l'UI)
      print('⚠️ Errore caricando medicalCard: $e');
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _birth = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final data = {
      'medicalCard': {
        'birthDate': _birth?.toIso8601String(),
        'bloodType': _bloodType,
        'allergies': _allergies.text.trim(),
        'conditions': _conditions.text.trim(),
        'therapy': _therapy.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medical card saved in your profile!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _allergies.dispose();
    _conditions.dispose();
    _therapy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Recupero il nome completo e lo mostro in alto:
    final fullName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    final parts = fullName.split(' ');
    final displayName = parts.join(' ');

    return Scaffold(
      appBar: AppBar(title: const Text('Medical Card')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Titolo con nome utente
              if (displayName.isNotEmpty) ...[
                Center(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Date of Birth picker
              GestureDetector(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _birth == null
                        ? 'Tap to select'
                        : DateFormat('dd/MM/yyyy').format(_birth!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Blood Type dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Blood Type',
                  border: OutlineInputBorder(),
                ),
                value: _bloodType,
                items:
                    _bloodTypes
                        .map(
                          (bt) => DropdownMenuItem(value: bt, child: Text(bt)),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _bloodType = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Allergies
              TextFormField(
                controller: _allergies,
                decoration: const InputDecoration(
                  labelText: 'Allergies',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Medical Conditions
              TextFormField(
                controller: _conditions,
                decoration: const InputDecoration(
                  labelText: 'Medical Conditions',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Therapy
              TextFormField(
                controller: _therapy,
                decoration: const InputDecoration(
                  labelText: 'Therapy',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
