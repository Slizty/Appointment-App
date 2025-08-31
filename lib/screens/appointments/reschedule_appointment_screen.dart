import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../services/data_service.dart';
import '../../services/notification_service.dart';

class RescheduleAppointmentScreen extends StatefulWidget {
  final String appointmentId;

  const RescheduleAppointmentScreen({super.key, required this.appointmentId});

  @override
  State<RescheduleAppointmentScreen> createState() => _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState extends State<RescheduleAppointmentScreen> {
  Appointment? _appointment;
  Doctor? _doctor;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  List<String> _availableSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  void _loadAppointment() {
    _appointment = DataService.getAppointmentById(widget.appointmentId);
    if (_appointment != null) {
      _doctor = DataService.getDoctorById(_appointment!.doctorId);
      setState(() {});
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTimeSlot = null;
      _loadAvailableSlots();
    });
  }

  void _loadAvailableSlots() {
    if (_selectedDate == null || _doctor == null) return;

    final weekday = _selectedDate!.weekday;
    final workDay = _doctor!.workDays.where((wd) => wd.weekday == weekday).firstOrNull;

    if (workDay == null) {
      _availableSlots = [];
      setState(() {});
      return;
    }

    final bookedSlots = DataService.getAppointmentsByDoctorAndDate(_doctor!.id, _selectedDate!)
        .where((apt) => apt.id != widget.appointmentId &&
        (apt.status == AppointmentStatus.pending || apt.status == AppointmentStatus.approved))
        .map((apt) => apt.timeSlot)
        .toList();

    _availableSlots = workDay.slots.where((slot) => !bookedSlots.contains(slot)).toList();
    setState(() {});
  }

  void _rescheduleAppointment() async {
    if (_selectedDate == null || _selectedTimeSlot == null || _appointment == null) return;

    setState(() => _isLoading = true);

    await NotificationService.cancelNotification(_appointment!.id);

    _appointment!.date = _selectedDate!;
    _appointment!.timeSlot = _selectedTimeSlot!;
    _appointment!.status = AppointmentStatus.pending;
    _appointment!.updatedAt = DateTime.now();

    await _appointment!.save();
    await NotificationService.scheduleAppointmentReminder(_appointment!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment rescheduled successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_appointment == null || _doctor == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reschedule Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Appointment', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Doctor: ${_doctor!.name}'),
                    Text('Date: ${DateFormat('MMM dd, yyyy').format(_appointment!.date)}'),
                    Text('Time: ${_appointment!.timeSlot}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Select New Date', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
    Container(
    height: 300,
    child: CalendarDatePicker(
    initialDate: DateTime.now().add(const Duration(days: 1)),
    firstDate: DateTime.now().add(const Duration(days: 1)),
    lastDate: DateTime.now().add(const Duration(days: 30)),
    onDateChanged: _onDateSelected,
    ),
    ),
            if (_selectedDate != null) ...[
              const SizedBox(height: 24),
              Text('Available Times', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Expanded(
                child: _availableSlots.isEmpty
                    ? const Center(child: Text('No available slots for this date'))
                    : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _availableSlots.length,
                  itemBuilder: (context, index) {
                    final slot = _availableSlots[index];
                    final isSelected = slot == _selectedTimeSlot;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedTimeSlot = slot),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
            onPressed: _selectedDate != null && _selectedTimeSlot != null && !_isLoading && _availableSlots.isNotEmpty
                ? _rescheduleAppointment
                : null,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Reschedule Appointment'),
        ),
      ),
    );
  }
}