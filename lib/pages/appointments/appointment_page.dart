// lib/pages/appointments/appointment_page.dart
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
      builder: (BuildContext context, Widget? child) {
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple.shade300,
              onPrimary: Colors.white,
              onSurface: Colors.deepPurple.shade300,
            ),
            timePickerTheme: TimePickerThemeData(
              hourMinuteTextStyle: AppTextStyles.title1(
                color: Colors.white,
              ).copyWith(
                fontWeight: FontWeight.w700,
                height: 2.8,
                textBaseline: TextBaseline.alphabetic,
              ),
              dialBackgroundColor: Colors.grey.shade200,
              dialTextStyle: AppTextStyles.buttons(
                color: Colors.black,
              ).copyWith(fontWeight: FontWeight.w600),
              helpTextStyle: AppTextStyles.body(color: Colors.black87),
              dayPeriodTextStyle: AppTextStyles.body(color: Colors.black87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              entryModeIconColor: Colors.black,
            ),
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: AppTextStyles.body(color: Colors.black87),
              hintStyle: AppTextStyles.body(color: Colors.black54),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple.shade300,
                textStyle: AppTextStyles.buttons(color: Colors.black),
              ),
            ),
          ),
          child: child!,
        );
      },
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

    final appointmentsRef = FirebaseFirestore.instance.collection(
      'appointments',
    );

    // Verifica conflitti
    final conflictQuery =
        await appointmentsRef
            .where('doctorName', isEqualTo: widget.doctorName)
            .where('startTime', isEqualTo: start.toIso8601String())
            .get();

    if (conflictQuery.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This doctor is already booked at that time.',
            style: AppTextStyles.body(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
    final userAppointmentsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('appointments');

    if (widget.appointmentId != null) {
      await userAppointmentsRef.doc(widget.appointmentId).update({
        'startTime': start.toIso8601String(),
        'endTime': end.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await userAppointmentsRef.add({
        'doctorName': widget.doctorName,
        'doctorSpecialty': widget.doctorSpecialty,
        'doctorImage': widget.doctorImagePath,
        'startTime': start.toIso8601String(),
        'endTime': end.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Salva anche globalmente per evitare conflitti
      await appointmentsRef.add({
        'userId': uid,
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Appointment with ${widget.doctorName}',
          style: AppTextStyles.link1(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCalendar(
          view: CalendarView.month,
          headerHeight: 60,
          headerStyle: CalendarHeaderStyle(
            textStyle: AppTextStyles.title1(color: Colors.deepPurple),
            textAlign: TextAlign.center,
          ),
          viewHeaderStyle: ViewHeaderStyle(
            dayTextStyle: AppTextStyles.buttons(color: Colors.black),
            dateTextStyle: AppTextStyles.body(color: Colors.grey.shade700),
          ),
          monthViewSettings: MonthViewSettings(
            showAgenda: true,
            monthCellStyle: MonthCellStyle(
              textStyle: AppTextStyles.body(),
              leadingDatesTextStyle: AppTextStyles.link(color: Colors.grey),
              trailingDatesTextStyle: AppTextStyles.body(color: Colors.grey),
            ),
            agendaStyle: AgendaStyle(
              dayTextStyle: AppTextStyles.link(color: Colors.black),
              dateTextStyle: AppTextStyles.body(),
              appointmentTextStyle: AppTextStyles.body(
                color: Colors.deepPurple,
              ),
            ),
          ),
          selectionDecoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          showNavigationArrow: true,
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

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
