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

  final _codiceFiscaleController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _medicoBaseController = TextEditingController();

  String? codiceFiscale;
  String? telefono;
  String? medicoBase;

  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchMedicalData();
  }

  Future<void> fetchMedicalData() async {
    if (user == null) return;
    final doc = await firestore.collection('users').doc(user!.uid).get();
    final data = doc.data();

    if (data != null) {
      setState(() {
        codiceFiscale = data['codiceFiscale'];
        telefono = data['telefono'];
        medicoBase = data['medicoBase'];

        _codiceFiscaleController.text = codiceFiscale ?? '';
        _telefonoController.text = telefono ?? '';
        _medicoBaseController.text = medicoBase ?? '';
      });
    }
  }

  Future<void> saveChanges() async {
    if (user == null) return;

    await firestore.collection('users').doc(user!.uid).set({
      'codiceFiscale': _codiceFiscaleController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'medicoBase': _medicoBaseController.text.trim(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informazioni salvate con successo')),
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
          style: AppTextStyles.title1(color: Colors.deepPurple),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.deepPurple),
            onPressed: () => setState(() => isEditing = !isEditing),
            tooltip: isEditing ? 'Annulla' : 'Modifica',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple[100],
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
                    if (!isEditing && codiceFiscale != null)
                      buildInfoRow('Fiscal Code', codiceFiscale!),
                    if (!isEditing && telefono != null)
                      buildInfoRow('Phone Number', telefono!),
                    if (!isEditing && medicoBase != null)
                      buildInfoRow('Medical Practitioner', medicoBase!),

                    if (isEditing)
                      Column(
                        children: [
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
                      ),
                  ],
                ),
              ),
            ),
            if (isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      saveChanges();
                    }
                  },
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
              ),
          ],
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
          if (value == null || value.isEmpty) {
            return 'Campo obbligatorio';
          }
          return null;
        },
      ),
    );
  }
}
