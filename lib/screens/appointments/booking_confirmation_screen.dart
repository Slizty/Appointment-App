import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../services/data_service.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String appointmentId = ModalRoute.of(context)?.settings.arguments as String;
    final Appointment? appointment = DataService.getAppointmentById(appointmentId);

    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirmation')),
        body: const Center(child: Text('Appointment not found')),
      );
    }

    final Doctor? doctor = DataService.getDoctorById(appointment.doctorId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Appointment Booked Successfully!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Doctor: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(doctor?.name ?? 'Unknown'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Specialty: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(doctor?.specialty ?? 'Unknown'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(DateFormat('EEEE, MMM dd, yyyy').format(appointment.date)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Time: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(appointment.timeSlot),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          appointment.status.name.toUpperCase(),
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your appointment is pending doctor approval.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                child: const Text('Go to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}