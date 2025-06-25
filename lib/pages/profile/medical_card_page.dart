// lib/pages/medical_card_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:medicare_app/theme/text_styles.dart';

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
      // Non blocchiamo l'UI
      debugPrint('⚠️ Errore caricando medicalCard: $e');
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
    final fullName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Your Name';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medical Card',
          style: AppTextStyles.title2(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // -------------------
              // Header con nome utente
              // -------------------
              Center(
                child: Text(
                  fullName,
                  style: AppTextStyles.title1(color: Colors.deepPurple[300]!),
                ),
              ),
              const SizedBox(height: 24),

              // -------------------
              // Sezione Medical Card
              // -------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date of Birth
                    Text(
                      'Date of Birth',
                      style: AppTextStyles.subtitle(color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: Text(
                          _birth == null
                              ? 'Tap to select'
                              : DateFormat('dd/MM/yyyy').format(_birth!),
                          style: AppTextStyles.body(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Blood Type
                    Text(
                      'Blood Type',
                      style: AppTextStyles.subtitle(color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: _bloodType,
                      items:
                          _bloodTypes
                              .map(
                                (bt) => DropdownMenuItem(
                                  value: bt,
                                  child: Text(
                                    bt,
                                    style: AppTextStyles.body(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _bloodType = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Allergies
                    Text(
                      'Allergies',
                      style: AppTextStyles.subtitle(color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _allergies,
                      decoration: InputDecoration(
                        hintText: 'Enter allergies',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: AppTextStyles.body(color: Colors.black),
                    ),
                    const SizedBox(height: 16),

                    // Medical Conditions
                    Text(
                      'Medical Conditions',
                      style: AppTextStyles.subtitle(color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _conditions,
                      decoration: InputDecoration(
                        hintText: 'Enter conditions',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: AppTextStyles.body(color: Colors.black),
                    ),
                    const SizedBox(height: 16),

                    // Therapy
                    Text(
                      'Therapy',
                      style: AppTextStyles.subtitle(color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _therapy,
                      decoration: InputDecoration(
                        hintText: 'Enter therapy',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: AppTextStyles.body(color: Colors.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // -------------------
              // Bottone Save
              // -------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[300],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                          : Text(
                            'Save',
                            style: AppTextStyles.buttons(color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
