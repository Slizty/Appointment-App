import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/doctor.dart';
import '../../models/appointment.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  static const Uuid _uuid = Uuid();
  Doctor? _doctor;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  List<String> _availableSlots = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String doctorId = ModalRoute.of(context)?.settings.arguments as String;
    _doctor = DataService.getDoctorById(doctorId);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTimeSlot = null;
      _availableSlots = _getAvailableSlotsForDate(date);
    });
  }

  List<String> _getAvailableSlotsForDate(DateTime date) {
    if (_doctor == null) return [];

    final weekday = date.weekday;
    final workDay = _doctor!.workDays.where((wd) => wd.weekday == weekday).firstOrNull;

    if (workDay == null) return [];

    // Filter out booked slots
    final bookedSlots = DataService.getAllAppointments()
        .where((apt) =>
    apt.doctorId == _doctor!.id &&
        apt.date.year == date.year &&
        apt.date.month == date.month &&
        apt.date.day == date.day &&
        (apt.status == AppointmentStatus.pending || apt.status == AppointmentStatus.approved))
        .map((apt) => apt.timeSlot)
        .toList();

    return workDay.slots.where((slot) => !bookedSlots.contains(slot)).toList();
  }

  Future<void> _bookAppointment() async {
    if (_selectedDate == null || _selectedTimeSlot == null) return;

    final currentUser = AuthService.getCurrentUser();
    if (currentUser == null) return;

    final appointment = Appointment(
      id: _uuid.v4(),
      doctorId: _doctor!.id,
      patientId: currentUser.id,
      date: _selectedDate!,
      timeSlot: _selectedTimeSlot!,
      status: AppointmentStatus.pending,
      createdAt: DateTime.now(),
    );

    await DataService.saveAppointment(appointment);
    await NotificationService.scheduleAppointmentReminder(appointment);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/booking_confirmation', arguments: appointment.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_doctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Appointment')),
        body: const Center(child: Text('Doctor not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Book with ${_doctor!.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor info
            Text(_doctor!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_doctor!.specialty, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),

            // Date selection
            const Text('Select Date:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = _selectedDate?.day == date.day &&
                      _selectedDate?.month == date.month;

                  return GestureDetector(
                    onTap: () => _onDateSelected(date),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('dd').format(date),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Time slots
            if (_selectedDate != null) ...[
              const Text('Available Times:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_availableSlots.isEmpty)
                const Text('No available slots for this date', style: TextStyle(color: Colors.grey))
              else
                Wrap(
                  spacing: 8,
                  children: _availableSlots.map((slot) {
                    final isSelected = _selectedTimeSlot == slot;
                    return ChoiceChip(
                      label: Text(slot),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTimeSlot = selected ? slot : null;
                        });
                      },
                    );
                  }).toList(),
                ),
            ],

            const Spacer(),

            // Book button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedDate != null && _selectedTimeSlot != null)
                    ? _bookAppointment
                    : null,
                child: const Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}