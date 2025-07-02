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
    /* final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ); */

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  Colors.deepPurple.shade300, // header e selezione lancetta
              onPrimary: Colors.white, // testo ore/minuti quando selezionati
              onSurface: Colors.deepPurple.shade300,
            ),

            timePickerTheme: TimePickerThemeData(
              // 1) Numeri grandi (ore/minuti) BIANCHI, thick, regolando height per riallineare i “:”
              hourMinuteTextStyle: AppTextStyles.title1(
                color: Colors.white,
              ).copyWith(
                fontWeight: FontWeight.w700,
                height: 2.8, // <1 = sale, >1 = scende. Gioca con questo valore
                textBaseline: TextBaseline.alphabetic,
              ),
              // 2) Sfondo del quadrante (dietro lancetta)
              dialBackgroundColor: Colors.grey.shade200,
              // 3) Numeri del quadrante (dial) NERI, font buttons
              dialTextStyle: AppTextStyles.buttons(
                color: Colors.black,
              ).copyWith(fontWeight: FontWeight.w600),
              // 4) Label “Select time” e “AM/PM” in body
              helpTextStyle: AppTextStyles.body(color: Colors.black87),
              dayPeriodTextStyle: AppTextStyles.body(color: Colors.black87),
              // 5) Dialog arrotondato
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // 6) Icone entry mode (tastierina/freccia) in nero
              entryModeIconColor: Colors.black,
            ),

            // Campi di input (modalità tastierina): label “Hour”/“Minute” in body
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: AppTextStyles.body(color: Colors.black87),
              hintStyle: AppTextStyles.body(color: Colors.black54),
            ),

            // Bottoni CANCEL/OK
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

        /* child: SfCalendar(
          view: CalendarView.month,
          dataSource: AppointmentDataSource(_appointments),
          backgroundColor: Colors.white,
          todayHighlightColor: Colors.deepPurple.shade300,
          selectionDecoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple),
          ),
          headerStyle: CalendarHeaderStyle(
            textAlign: TextAlign.center,
            textStyle: AppTextStyles.title2(color: Colors.deepPurple),
          ),
          viewHeaderStyle: ViewHeaderStyle(
            dayTextStyle: AppTextStyles.body(color: Colors.black),
            dateTextStyle: AppTextStyles.body(color: Colors.grey[700]!),
          ),
          monthViewSettings: MonthViewSettings(
            showAgenda: true,
            agendaStyle: AgendaStyle(
              appointmentTextStyle: AppTextStyles.body(color: Colors.black),
              dateTextStyle: AppTextStyles.body(color: Colors.deepPurple),
              dayTextStyle: AppTextStyles.link1(color: Colors.black),
            ),

            appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
          ),
          onTap: (details) {
            if (details.targetElement == CalendarElement.calendarCell &&
                details.date != null) {
              _bookAppointment(details.date!);
            }
          },
        ), */
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

/// Public CalendarDataSource for appointments
class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
