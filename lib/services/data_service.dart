import 'package:hive_flutter/hive_flutter.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/user.dart';

class DataService {
  static const String _doctorsBox = 'doctors';
  static const String _appointmentsBox = 'appointments';
  static const String _usersBox = 'users';
  static const String _currentUserBox = 'current_user';

  // Initialize Hive boxes
  static Future<void> init() async {
    // Register adapters
    Hive.registerAdapter(DoctorAdapter());
    Hive.registerAdapter(WorkDayAdapter());
    Hive.registerAdapter(AppointmentAdapter());
    Hive.registerAdapter(AppointmentStatusAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(UserRoleAdapter());

    // Open boxes
    await Hive.openBox<Doctor>(_doctorsBox);
    await Hive.openBox<Appointment>(_appointmentsBox);
    await Hive.openBox<User>(_usersBox);
    await Hive.openBox(_currentUserBox);
  }

  // Public box getters (removed underscore)
  static Box<Doctor> get doctorsBox => Hive.box<Doctor>(_doctorsBox);
  static Box<Appointment> get appointmentsBox =>
      Hive.box<Appointment>(_appointmentsBox);
  static Box<User> get usersBox => Hive.box<User>(_usersBox);
  static Box get currentUserBox => Hive.box(_currentUserBox);

  // Doctor methods
  static Future<void> saveDoctors(List<Doctor> doctors) async {
    final box = doctorsBox;
    await box.clear();
    for (var doctor in doctors) {
      await box.put(doctor.id, doctor);
    }
  }

  static List<Doctor> getAllDoctors() {
    return doctorsBox.values.toList();
  }

  static Doctor? getDoctorById(String id) {
    return doctorsBox.get(id);
  }

  // User methods
  static Future<void> saveUser(User user) async {
    await usersBox.put(user.id, user);
  }

  static Future<void> setCurrentUser(String userId) async {
    await currentUserBox.put('current_user_id', userId);
  }

  static String? getCurrentUserId() {
    return currentUserBox.get('current_user_id');
  }

  static User? getCurrentUser() {
    final userId = getCurrentUserId();
    if (userId != null) {
      return usersBox.get(userId);
    }
    return null;
  }

  // Appointment methods
  static Future<void> saveAppointment(Appointment appointment) async {
    await appointmentsBox.put(appointment.id, appointment);
  }

  static List<Appointment> getAllAppointments() {
    return appointmentsBox.values.toList();
  }

  static List<Appointment> getAppointmentsByUserId(String userId) {
    return appointmentsBox.values
        .where((appointment) => appointment.patientId == userId)
        .toList();
  }

  static Appointment? getAppointmentById(String id) {
    return appointmentsBox.get(id);
  }

  static List<Appointment> getAppointmentsByDoctorAndDate(
      String doctorId, DateTime date) {
    return appointmentsBox.values.where((appointment) {
      return appointment.doctorId == doctorId &&
          appointment.date.year == date.year &&
          appointment.date.month == date.month &&
          appointment.date.day == date.day;
    }).toList();
  }
}
