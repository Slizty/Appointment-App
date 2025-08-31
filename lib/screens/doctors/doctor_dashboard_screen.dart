import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../services/notification_service.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  List<Appointment> _appointments = [];
  Doctor? _currentDoctor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    final currentUser = AuthService.getCurrentUser();
    if (currentUser != null) {
      // Get doctor info
      _currentDoctor = await DataService.getDoctorById(currentUser.doctorId!);

      // Get doctor's appointments
      final allAppointments = await DataService.getAllAppointments();
      final now = DateTime.now();

      _appointments = allAppointments
          .where((apt) => apt.doctorId == currentUser.doctorId)
          .map((apt) {
        // Auto-mark approved appointments as completed when their time arrives
        if (apt.appointmentDateTime.isBefore(now) && apt.status == AppointmentStatus.approved) {
          apt.status = AppointmentStatus.completed;
          apt.updatedAt = DateTime.now();
          DataService.saveAppointment(apt);
          NotificationService.scheduleAppointmentCompleted(apt);
        }
        // Auto-mark pending/declined appointments as missed when their time passes
        else if (apt.appointmentDateTime.isBefore(now) &&
            (apt.status == AppointmentStatus.pending || apt.status == AppointmentStatus.declined)) {
          apt.status = AppointmentStatus.autoMissed;
          apt.updatedAt = DateTime.now();
          DataService.saveAppointment(apt);
        }
        return apt;
      }).toList();

      // Sort by appointment date and time
      _appointments.sort(
          (a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _approveAppointment(Appointment appointment) async {
    final updatedAppointment = Appointment(
      id: appointment.id,
      doctorId: appointment.doctorId,
      patientId: appointment.patientId,
      date: appointment.date,
      timeSlot: appointment.timeSlot,
      status: AppointmentStatus.approved,
      createdAt: appointment.createdAt,
      updatedAt: DateTime.now(),
    );

    await DataService.saveAppointment(updatedAppointment);
    await NotificationService.scheduleAppointmentApproved(updatedAppointment);

    _loadDoctorData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment approved')),
    );
  }

  Future<void> _declineAppointment(Appointment appointment) async {
    final updatedAppointment = Appointment(
      id: appointment.id,
      doctorId: appointment.doctorId,
      patientId: appointment.patientId,
      date: appointment.date,
      timeSlot: appointment.timeSlot,
      status: AppointmentStatus.declined,
      createdAt: appointment.createdAt,
      updatedAt: DateTime.now(),
    );

    await DataService.saveAppointment(updatedAppointment);
    await NotificationService.scheduleAppointmentDeclined(updatedAppointment);

    _loadDoctorData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment declined')),
    );
  }



  Future<void> _rescheduleAppointment(Appointment appointment) async {
    // Navigate to reschedule screen
    Navigator.pushNamed(
      context,
      '/reschedule_appointment',
      arguments: appointment.id,
    ).then((_) => _loadDoctorData());
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/signin');
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.approved:
        return Colors.green;
      case AppointmentStatus.declined:
        return Colors.red;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.cancelled:
        return Colors.grey;
      case AppointmentStatus.autoMissed:
        return Colors.red.shade300;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.approved:
        return 'Approved';
      case AppointmentStatus.declined:
        return 'Declined';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.autoMissed:
        return 'Auto-Missed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. ${_currentDoctor?.name ?? "Dashboard"}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Doctor Info Card
                if (_currentDoctor != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade400, Colors.teal.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 32,
                              backgroundImage:
                                  NetworkImage(_currentDoctor!.avatarUrl),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dr. ${_currentDoctor!.name}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentDoctor!.specialty,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Appointments Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.event_note,
                          color: Colors.teal.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Appointments',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade600,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_appointments.length} total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Appointments List
                Expanded(
                  child: _appointments.isEmpty
                      ? const Center(
                          child: Text(
                            'No appointments found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = _appointments[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.calendar_today,
                                            color: Colors.teal.shade600,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                DateFormat('MMM dd, yyyy')
                                                    .format(appointment.date),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    appointment.timeSlot,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                appointment.status),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            _getStatusText(appointment.status),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.person_outline,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Patient ID: ${appointment.patientId}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Action buttons for pending appointments
                                    if (appointment.status ==
                                        AppointmentStatus.pending) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 36,
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _approveAppointment(
                                                        appointment),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.check,
                                                        size: 14),
                                                    const SizedBox(width: 4),
                                                    const Flexible(
                                                      child: Text(
                                                        'Approve',
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Container(
                                              height: 36,
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _declineAppointment(
                                                        appointment),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.close,
                                                        size: 14),
                                                    const SizedBox(width: 4),
                                                    const Flexible(
                                                      child: Text(
                                                        'Decline',
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Container(
                                              height: 36,
                                              child: OutlinedButton(
                                                onPressed: () =>
                                                    _rescheduleAppointment(
                                                        appointment),
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  side: const BorderSide(
                                                      color: Colors.blue),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.schedule,
                                                        size: 14,
                                                        color: Colors.blue),
                                                    const SizedBox(width: 4),
                                                    const Flexible(
                                                      child: Text(
                                                        'Reschedule',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.blue),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],


                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
