import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';

class MissedAppointmentsScreen extends StatefulWidget {
  const MissedAppointmentsScreen({super.key});

  @override
  State<MissedAppointmentsScreen> createState() => _MissedAppointmentsScreenState();
}

class _MissedAppointmentsScreenState extends State<MissedAppointmentsScreen> {
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
          .where((apt) {
        // Auto-mark approved appointments as completed when their time arrives
        if (apt.appointmentDateTime.isBefore(now) && apt.status == AppointmentStatus.approved) {
          apt.status = AppointmentStatus.completed;
          apt.updatedAt = DateTime.now();
          DataService.saveAppointment(apt);
        }
        // Auto-mark pending/declined appointments as missed when their time passes
        else if (apt.appointmentDateTime.isBefore(now) &&
            (apt.status == AppointmentStatus.pending || apt.status == AppointmentStatus.declined)) {
          apt.status = AppointmentStatus.autoMissed;
          apt.updatedAt = DateTime.now();
          DataService.saveAppointment(apt);
        }
        return (apt.status == AppointmentStatus.cancelled || apt.status == AppointmentStatus.autoMissed) && apt.appointmentDateTime.isBefore(now);
      }).toList();

      _appointments.sort((a, b) => b.appointmentDateTime.compareTo(a.appointmentDateTime)); // Most recent first
      setState(() {});
    }
  }

  void _showRescheduleDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Appointment'),
        content: const Text('Would you like to reschedule this missed appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/reschedule_appointment',
                arguments: appointment.id,
              );
            },
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Missed Appointments'),
        automaticallyImplyLeading: false,
      ),
      body: _appointments.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No missed appointments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(
              'Great job keeping up with your appointments!',
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
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'MISSED',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.blue),
                onPressed: () => _showRescheduleDialog(appointment),
                tooltip: 'Reschedule',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}