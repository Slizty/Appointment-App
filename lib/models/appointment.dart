import 'package:hive/hive.dart';

part 'appointment.g.dart';

@HiveType(typeId: 2)
class Appointment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String doctorId;

  @HiveField(2)
  String patientId;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String timeSlot;

  @HiveField(5)
  AppointmentStatus status;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get the full appointment DateTime by combining date and timeSlot
  DateTime get appointmentDateTime {
    // Parse time from timeSlot (e.g., "9:00 AM" or "14:30")
    final timeParts = timeSlot.replaceAll(RegExp(r'[^0-9:]'), '').split(':');
    int hour = int.parse(timeParts[0]);
    int minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
    
    // Handle AM/PM format
    if (timeSlot.toUpperCase().contains('PM') && hour != 12) {
      hour += 12;
    } else if (timeSlot.toUpperCase().contains('AM') && hour == 12) {
      hour = 0;
    }
    
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// Check if appointment is currently active (within 1 hour of appointment time)
  bool get isCurrentlyActive {
    final now = DateTime.now();
    final appointmentTime = appointmentDateTime;
    final oneHourAfter = appointmentTime.add(const Duration(hours: 1));
    
    return now.isAfter(appointmentTime) && now.isBefore(oneHourAfter);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

@HiveType(typeId: 3)
enum AppointmentStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  approved,

  @HiveField(2)
  declined,

  @HiveField(3)
  completed,

  @HiveField(4)
  cancelled,

  @HiveField(5)
  autoMissed,
}