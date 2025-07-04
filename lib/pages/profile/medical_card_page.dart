// lib/pages/medical_card_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:medicare_app/theme/text_styles.dart';

class MedicalCardPage extends StatefulWidget {
  const MedicalCardPage({Key? key}) : super(key: key);

  @override
  State<MedicalCardPage> createState() => _MedicalCardPageState();
}

class _MedicalCardPageState extends State<MedicalCardPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _birth;
  String? _bloodType;
  final _fiscalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _residenceController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _therapyController = TextEditingController();

  final _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    _fiscalCodeController.text = data['fiscalCode'] ?? '';
    _phoneController.text = data['phone'] ?? '';
    _residenceController.text = data['residence'] ?? '';
    final mc = data['medicalCard'] as Map<String, dynamic>?;
    if (mc != null) {
      setState(() {
        _birth =
            mc['birthDate'] != null ? DateTime.parse(mc['birthDate']) : null;
        _bloodType = mc['bloodType'];
        _allergiesController.text = mc['allergies'] ?? '';
        _conditionsController.text = mc['conditions'] ?? '';
        _therapyController.text = mc['therapy'] ?? '';
      });
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.deepPurple.shade300,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  textStyle: AppTextStyles.buttons(
                    color: Colors.deepPurple.shade300,
                  ),
                ),
              ),
            ),
            child: child!,
          ),
    );
    if (d != null) setState(() => _birth = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final updateData = {
      'fiscalCode': _fiscalCodeController.text.trim(),
      'phone': _phoneController.text.trim(),
      'residence': _residenceController.text.trim(),
      'medicalCard': {
        'birthDate': _birth?.toIso8601String(),
        'bloodType': _bloodType,
        'allergies': _allergiesController.text.trim(),
        'conditions': _conditionsController.text.trim(),
        'therapy': _therapyController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    };
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(updateData, SetOptions(merge: true));
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.deepPurple.shade300,
        content: Text(
          'Profile updated',
          style: AppTextStyles.buttons(color: Colors.white),
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _fiscalCodeController.dispose();
    _phoneController.dispose();
    _residenceController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _therapyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medical Card & Info',
          style: AppTextStyles.subtitle(
            color: Colors.white,
          ).copyWith(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.deepPurple.shade200,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          fullName,
                          style: AppTextStyles.title1(
                            color: Colors.deepPurple.shade300,
                          ).copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Anagrafica
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'General Information',
                              style: AppTextStyles.subtitle(
                                color: Colors.deepPurple.shade400,
                              ).copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: 'Tax Code',
                              controller: _fiscalCodeController,
                              validator:
                                  (v) => v!.trim().isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: 'Phone',
                              controller: _phoneController,
                              keyboard: TextInputType.phone,
                              validator:
                                  (v) => v!.trim().isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: 'Residence',
                              controller: _residenceController,
                              validator:
                                  (v) => v!.trim().isEmpty ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Medical Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Medical Information',
                              style: AppTextStyles.subtitle(
                                color: Colors.deepPurple.shade400,
                              ).copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            _buildDatePicker(),
                            const SizedBox(height: 16),
                            _buildDropdown(),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Allergies',
                              controller: _allergiesController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Conditions',
                              controller: _conditionsController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Therapy',
                              controller: _therapyController,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: AppTextStyles.buttons(
                            color: Colors.white,
                          ).copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      style: AppTextStyles.buttons(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.buttons(color: Colors.grey[700]!),
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: AppTextStyles.buttons(color: Colors.black),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDate,
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(
                  color: Colors.deepPurple.shade300,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              _birth == null
                  ? 'Tap to select'
                  : DateFormat('dd/MM/yyyy').format(_birth!),
              style: AppTextStyles.buttons(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Type',
          style: AppTextStyles.body(
            color: Colors.black,
          ).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: Colors.deepPurple.shade300,
                width: 2,
              ),
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
                        style: AppTextStyles.buttons(color: Colors.black),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (v) => setState(() => _bloodType = v),
          validator: (v) => v == null ? 'Required' : null,
        ),
      ],
    );
  }
}
