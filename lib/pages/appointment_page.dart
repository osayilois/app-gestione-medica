import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AppointmentPage extends StatefulWidget {
  final String doctorName;

  AppointmentPage({required this.doctorName});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  List<Appointment> _appointments = [];

  void _bookAppointment(DateTime date) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final appointmentDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      setState(() {
        _appointments.add(
          Appointment(
            startTime: appointmentDateTime,
            endTime: appointmentDateTime.add(Duration(minutes: 30)),
            subject: 'Appointment with ${widget.doctorName}',
            color: Colors.deepPurple,
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appointment booked with ${widget.doctorName} on ${appointmentDateTime.toLocal().toString().split(".")[0]}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Appointment with ${widget.doctorName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCalendar(
          view: CalendarView.month,
          dataSource: _AppointmentDataSource(_appointments),
          monthViewSettings: MonthViewSettings(
            showAgenda: true,
            appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
          ),
          onTap: (CalendarTapDetails details) {
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
