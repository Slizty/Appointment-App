import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/doctor.dart';
import '../../services/data_service.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String doctorId = ModalRoute.of(context)?.settings.arguments as String;
    final Doctor? doctor = DataService.getDoctorById(doctorId);

    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Doctor Not Found')),
        body: const Center(child: Text('Doctor not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(doctor.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor info
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(doctor.avatarUrl),
                  onBackgroundImageError: (_, __) {},
                  child: const Icon(Icons.person, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(doctor.specialty, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Available Times:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Available times
            Expanded(
              child: ListView.builder(
                itemCount: doctor.workDays.length,
                itemBuilder: (context, index) {
                  final workDay = doctor.workDays[index];
                  final dayName = DateFormat('EEEE').format(DateTime.now().add(Duration(days: workDay.weekday - DateTime.now().weekday)));

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: workDay.slots.map((slot) =>
                                Chip(label: Text(slot))).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Book appointment button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/book_appointment',
                    arguments: doctorId,
                  );
                },
                child: const Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}