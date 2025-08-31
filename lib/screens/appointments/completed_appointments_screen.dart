import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';

class CompletedAppointmentsScreen extends StatefulWidget {
  const CompletedAppointmentsScreen({super.key});

  @override
  State<CompletedAppointmentsScreen> createState() => _CompletedAppointmentsScreenState();
}

class _CompletedAppointmentsScreenState extends State<CompletedAppointmentsScreen> {
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    final currentUser = AuthService.getCurrentUser();
    if (currentUser != null) {
      _appointments = DataService.getAppointmentsByUserId(currentUser.id)
          .where((apt) => apt.status == AppointmentStatus.completed)
          .toList();

      _appointments.sort((a, b) => b.appointmentDateTime.compareTo(a.appointmentDateTime)); // Most recent first
      setState(() {});
    }
  }

  void _showAppointmentDetails(Appointment appointment) {
    final doctor = DataService.getDoctorById(appointment.doctorId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor: ${doctor?.name ?? 'Unknown'}'),
            Text('Specialty: ${doctor?.specialty ?? 'Unknown'}'),
            Text('Date: ${DateFormat('MMM dd, yyyy').format(appointment.date)}'),
            Text('Time: ${appointment.timeSlot}'),
            Text('Completed: ${DateFormat('MMM dd, yyyy').format(appointment.updatedAt ?? appointment.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _bookAgain(doctor);
            },
            child: const Text('Book Again'),
          ),
        ],
      ),
    );
  }

  void _bookAgain(Doctor? doctor) {
    if (doctor != null) {
      Navigator.pushNamed(
        context,
        '/doctor_profile',
        arguments: doctor.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Appointments'),
        automaticallyImplyLeading: false,
      ),
      body: _appointments.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No completed appointments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(
              'Your appointment history will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'COMPLETED',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.blue),
                onPressed: () => _showAppointmentDetails(appointment),
                tooltip: 'View Details',
              ),
              isThreeLine: true,
              onTap: () => _showAppointmentDetails(appointment),
            ),
          );
        },
      ),
    );
  }
}