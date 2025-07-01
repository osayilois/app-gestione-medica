import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentPage extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String doctorImagePath;
  final String? appointmentId;

  const AppointmentPage({
    super.key,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImagePath,
    this.appointmentId,
  });

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final List<Appointment> _appointments = [];

  Future<void> _bookAppointment(DateTime date) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final start = DateTime(
      date.year,
      date.month,
      date.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    final end = start.add(const Duration(minutes: 30));

    setState(() {
      _appointments.add(
        Appointment(
          startTime: start,
          endTime: end,
          subject: 'Appointment with ${widget.doctorName}',
          color: Colors.deepPurple,
        ),
      );
    });

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final appointmentsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('appointments');

    if (widget.appointmentId != null) {
      // Modifica appuntamento esistente
      await appointmentsRef.doc(widget.appointmentId).update({
        'startTime': start.toIso8601String(),
        'endTime': end.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Crea nuovo appuntamento
      await appointmentsRef.add({
        'doctorName': widget.doctorName,
        'doctorSpecialty': widget.doctorSpecialty,
        'doctorImage': widget.doctorImagePath,
        'startTime': start.toIso8601String(),
        'endTime': end.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Appointment booked with ${widget.doctorName} on ${DateFormat('dd/MM/yyyy HH:mm').format(start)}',
          style: AppTextStyles.body(color: Colors.white),
        ),
      ),
    );
    Navigator.pop(context); // Torna alla pagina precedente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Appointment with ${widget.doctorName}'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCalendar(
          view: CalendarView.month,
          dataSource: AppointmentDataSource(_appointments),
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

/// Public CalendarDataSource for appointments
class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
