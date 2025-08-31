import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/appointment.dart';
import '../models/doctor.dart';
import 'data_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(settings);
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleAppointmentReminder(
      Appointment appointment) async {
    final doctor = DataService.getDoctorById(appointment.doctorId);
    if (doctor == null) return;

    final reminderTime = appointment.date.subtract(const Duration(hours: 1));
    if (reminderTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      appointment.id.hashCode,
      'Appointment Reminder',
      'You have an appointment with ${doctor.name} in 1 hour at ${appointment.timeSlot}',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointment_reminders',
          'Appointment Reminders',
          channelDescription: 'Reminders for upcoming appointments',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelNotification(String appointmentId) async {
    await _notifications.cancel(appointmentId.hashCode);
  }

  static Future<void> scheduleAppointmentCreated(
      Appointment appointment) async {
    final doctor = DataService.getDoctorById(appointment.doctorId);
    if (doctor == null) return;

    await _notifications.show(
      appointment.id.hashCode + 1000,
      'Appointment Booked',
      'Your appointment with ${doctor.name} is scheduled for ${appointment.timeSlot}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointment_updates',
          'Appointment Updates',
          channelDescription: 'Updates about appointment status',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> scheduleAppointmentCancelled(
      Appointment appointment) async {
    final doctor = DataService.getDoctorById(appointment.doctorId);
    if (doctor == null) return;

    await cancelNotification(appointment.id);

    await _notifications.show(
      appointment.id.hashCode + 2000,
      'Appointment Cancelled',
      'Your appointment with ${doctor.name} has been cancelled',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointment_updates',
          'Appointment Updates',
          channelDescription: 'Updates about appointment status',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> scheduleAppointmentApproved(
      Appointment appointment) async {
    final doctor = DataService.getDoctorById(appointment.doctorId);
    if (doctor == null) return;

    await _notifications.show(
      appointment.id.hashCode + 3000,
      'Appointment Approved',
      'Your appointment with ${doctor.name} has been approved for ${appointment.timeSlot}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointment_updates',
          'Appointment Updates',
          channelDescription: 'Updates about appointment status',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> scheduleAppointmentDeclined(
      Appointment appointment) async {
    final doctor = DataService.getDoctorById(appointment.doctorId);
    if (doctor == null) return;

    await _notifications.show(
      appointment.id.hashCode + 4000,
      'Appointment Declined',
      'Your appointment with ${doctor.name} has been declined',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointment_updates',
          'Appointment Updates',
          channelDescription: 'Updates about appointment status',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> scheduleAppointmentCompleted(
      Appointment appointment) async {
    final doctor = DataService.getDoctorById(appointment.doctorId);
    if (doctor == null) return;

    await _notifications.show(
      appointment.id.hashCode + 5000,
      'Appointment Completed',
      'Your appointment with ${doctor.name} has been completed',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointment_updates',
          'Appointment Updates',
          channelDescription: 'Updates about appointment status',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
