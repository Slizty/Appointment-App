import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'data_service.dart';

class AuthService {
  static const Uuid _uuid = Uuid();
  
  // Doctor login codes (10 digits)
  static const Map<String, String> _doctorCodes = {
    '1111111111': 'd1', // Dr. Amina Khaled - Cardiology
    '2222222222': 'd2', // Dr. Omar Hassan - Dermatology  
    '3333333333': 'd3', // Dr. Nour El-Din - Pediatrics
  };

  static Future<bool> signInWithPhone(String phoneNumber) async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Check if phone number is a doctor code
  static bool isDoctorCode(String phoneNumber) {
    return _doctorCodes.containsKey(phoneNumber);
  }
  
  // Get doctor ID from code
  static String? getDoctorIdFromCode(String phoneNumber) {
    return _doctorCodes[phoneNumber];
  }
  
  // Doctor login (skip OTP)
  static Future<User?> doctorLogin(String phoneNumber) async {
    try {
      final doctorId = getDoctorIdFromCode(phoneNumber);
      if (doctorId == null) return null;
      
      // Check if doctor user already exists
      final allUsers = DataService.usersBox.values.toList();
      final existingDoctors = allUsers.where((user) => 
          user.phoneNumber == phoneNumber && user.role == UserRole.doctor).toList();
      
      User doctorUser;
      if (existingDoctors.isNotEmpty) {
        doctorUser = existingDoctors.first;
        // Update doctorId if not set
        if (doctorUser.doctorId != doctorId) {
          doctorUser.doctorId = doctorId;
          await DataService.saveUser(doctorUser);
        }
      } else {
        // Create doctor user
        doctorUser = User(
          id: _uuid.v4(), // Generate unique user ID
          phoneNumber: phoneNumber,
          role: UserRole.doctor,
          createdAt: DateTime.now(),
          doctorId: doctorId, // Set the doctor ID
        );
        await DataService.saveUser(doctorUser);
      }
      
      await DataService.setCurrentUser(doctorUser.id);
      return doctorUser;
    } catch (e) {
      print('Error in doctor login: $e');
      return null;
    }
  }

  static Future<User?> verifyOTP(String phoneNumber, String otp) async {
    try {
      if (otp.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(otp)) {
        return null;
      }

      // Check if user already exists - use public getter
      final allUsers = DataService.usersBox.values.toList();
      final existingUsers =
          allUsers.where((user) => user.phoneNumber == phoneNumber).toList();

      User user;
      if (existingUsers.isNotEmpty) {
        user = existingUsers.first;
      } else {
        user = User(
          id: _uuid.v4(),
          phoneNumber: phoneNumber,
          role: UserRole.patient,
          createdAt: DateTime.now(),
        );
        await DataService.saveUser(user);
      }

      await DataService.setCurrentUser(user.id);
      return user;
    } catch (e) {
      print('Error verifying OTP: $e');
      return null;
    }
  }

  static bool isLoggedIn() {
    return DataService.getCurrentUserId() != null;
  }

  static User? getCurrentUser() {
    return DataService.getCurrentUser();
  }
  
  // Check if current user is a doctor
  static bool isCurrentUserDoctor() {
    final user = getCurrentUser();
    return user?.role == UserRole.doctor;
  }

  static Future<void> logout() async {
    await DataService.currentUserBox.delete('current_user_id');
  }
}
