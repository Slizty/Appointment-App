import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

class UpcomingAppointmentsScreen extends StatefulWidget {
  const UpcomingAppointmentsScreen({super.key});

  @override
  State<UpcomingAppointmentsScreen> createState() => _UpcomingAppointmentsScreenState();
}

class _UpcomingAppointmentsScreenState extends State<UpcomingAppointmentsScreen> {
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    final currentUser = AuthService.getCurrentUser();
    if (currentUser != null) {
      final now = DateTime.now();
      _appointments = DataService.getAppointmentsByUserId(currentUser.id)
          .where((apt) =>
      (apt.status == AppointmentStatus.pending || apt.status == AppointmentStatus.approved) &&
          apt.appointmentDateTime.isAfter(now))
          .toList();
      _appointments.sort((a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime));
      setState(() {});
    }
  }

  void _showOptionsDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Reschedule'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/reschedule_appointment',
                  arguments: appointment.id,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancel'),
              onTap: () {
                Navigator.pop(context);
                _cancelAppointment(appointment);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _cancelAppointment(Appointment appointment) async {
    appointment.status = AppointmentStatus.cancelled;
    appointment.updatedAt = DateTime.now();
    await appointment.save();
    await NotificationService.cancelNotification(appointment.id);
    await NotificationService.scheduleAppointmentCancelled(appointment);
    _loadAppointments();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment cancelled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Appointments'),
        automaticallyImplyLeading: false,
      ),
      body: _appointments.isEmpty
          ? const Center(
        child: Text(
          'No upcoming appointments',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          final doctor = DataService.getDoctorById(appointment.doctorId);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: doctor != null ? AssetImage(doctor.avatarUrl) : null,
                child: doctor == null ? const Icon(Icons.person) : null,
              ),
              title: Text(doctor?.name ?? 'Unknown Doctor'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor?.specialty ?? 'Unknown Specialty'),
                  Text('${DateFormat('MMM dd, yyyy').format(appointment.date)} at ${appointment.timeSlot}'),
                  Text(
                    'Status: ${appointment.status.name.toUpperCase()}',
                    style: TextStyle(
                      color: appointment.status == AppointmentStatus.approved
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptionsDialog(appointment),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}