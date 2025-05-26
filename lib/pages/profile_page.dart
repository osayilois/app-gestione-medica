import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/theme/text_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool isEditing = false;

  // Campi modificabili
  final TextEditingController _codiceFiscaleController =
      TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _medicoBaseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
          'Profilo',
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
            // Immagine profilo
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),

            const SizedBox(height: 20),

            // Blocco info lilla
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
                    buildInfoRow('Nome', nome),
                    buildInfoRow('Cognome', cognome),
                    buildInfoRow('Email', email),
                    const SizedBox(height: 12),
                    buildEditableField(
                      'Codice Fiscale',
                      _codiceFiscaleController,
                    ),
                    buildEditableField(
                      'Telefono',
                      _telefonoController,
                      keyboard: TextInputType.phone,
                    ),
                    buildEditableField('Medico di base', _medicoBaseController),
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
                      // Salvataggio dati
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Informazioni salvate.')),
                      );
                      setState(() => isEditing = false);
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
                    'Salva modifiche',
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
        enabled: isEditing,
        keyboardType: keyboard,
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
            return 'Campo obbligatorio';
          }
          return null;
        },
      ),
    );
  }
}
