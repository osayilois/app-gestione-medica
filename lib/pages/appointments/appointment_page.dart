// lib/pages/appointment_page.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentPage extends StatefulWidget {
  final String doctorName;
  const AppointmentPage({super.key, required this.doctorName});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final List<Appointment> _appointments = [];

  Future<void> _bookAppointment(DateTime date) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final appointmentDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    final endDateTime = appointmentDateTime.add(const Duration(minutes: 30));

    // 1) Aggiungi localmente
    setState(() {
      _appointments.add(
        Appointment(
          startTime: appointmentDateTime,
          endTime: endDateTime,
          subject: 'Appointment with ${widget.doctorName}',
          color: Colors.deepPurple,
        ),
      );
    });

    // 2) Salva su Firestore
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .add({
          'doctorName': widget.doctorName,
          'startTime': appointmentDateTime.toIso8601String(),
          'endTime': endDateTime.toIso8601String(),
          'createdAt': FieldValue.serverTimestamp(),
        });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Appointment booked with ${widget.doctorName} on '
          '${appointmentDateTime.toLocal().toString().split(".")[0]}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Appointment with ${widget.doctorName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCalendar(
          view: CalendarView.month,
          dataSource: _AppointmentDataSource(_appointments),
          monthViewSettings: const MonthViewSettings(
            showAgenda: true,
            appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
          ),
          onTap: (details) {
            if (details.targetElement == CalendarElement.calendarCell &&
                details.date != null) {
              _bookAppointment(details.date!);
            }
          },
        ),
      ),
    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
