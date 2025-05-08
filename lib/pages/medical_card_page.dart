import 'package:flutter/material.dart';

class MedicalCardPage extends StatefulWidget {
  const MedicalCardPage({super.key});

  @override
  _MedicalCardPageState createState() => _MedicalCardPageState();
}

class _MedicalCardPageState extends State<MedicalCardPage> {
  // Controller per ogni campo di input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();

  // Lista dei gruppi sanguigni e variabile per quello selezionato
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  String? _selectedBloodType;

  void _saveMedicalCard() {
    // Qui potresti salvare i dati localmente o su un server
    print('Name: ${_nameController.text}');
    print('Age: ${_ageController.text}');
    print('Blood Type: $_selectedBloodType');
    print('Allergies: ${_allergiesController.text}');
    print('Medical Conditions: ${_conditionsController.text}');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Medical card saved!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medical Card')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            // Dropdown per il gruppo sanguigno
            DropdownButtonFormField<String>(
              value: _selectedBloodType,
              items:
                  _bloodTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBloodType = newValue;
                });
              },
              decoration: InputDecoration(
                labelText: 'Blood Type',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _allergiesController,
              decoration: InputDecoration(labelText: 'Allergies'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _conditionsController,
              decoration: InputDecoration(labelText: 'Medical Conditions'),
            ),
            SizedBox(height: 30),
            ElevatedButton(onPressed: _saveMedicalCard, child: Text('Save')),
          ],
        ),
      ),
    );
  }
}
