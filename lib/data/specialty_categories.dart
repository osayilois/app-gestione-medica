// lib/data/specialty_categories.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

final List<Map<String, dynamic>> specialtyCategories = [
  {
    'name': 'All',
    'iconData': FontAwesomeIcons.borderAll,
    'color': Colors.deepPurple.shade300,
  },
  {
    'name': 'Cardiologist',
    'iconData': MdiIcons.heartPulse,
    'color': Colors.red.shade300,
  },
  {'name': 'Dentist', 'iconData': MdiIcons.tooth, 'color': Colors.blue},
  {
    'name': 'Eye Specialist',
    'iconData': FontAwesomeIcons.solidEye,
    'color': Colors.orange.shade300,
  },
  {
    'name': 'Orthopaedic',
    'iconData': Icons.wheelchair_pickup_sharp,
    'color': Colors.teal.shade300,
  },
  {
    'name': 'Paediatrician',
    'iconData': FontAwesomeIcons.baby,
    'color': Colors.green.shade300,
  },
  {
    'name': 'Surgeon',
    'iconData': FontAwesomeIcons.stethoscope,
    'color': Colors.purple.shade300,
  },
  {
    'name': 'Dermatologist',
    'iconData': MdiIcons.faceManShimmer,
    'color': Colors.brown.shade300,
  },
  {
    'name': 'Gynecologist',
    'iconData': MdiIcons.humanPregnant,
    'color': Colors.pink.shade300,
  },
];
