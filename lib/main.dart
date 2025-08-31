import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/data_service.dart';
import 'services/seed_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding1_screen.dart';
import 'screens/onboarding/onboarding2_screen.dart';
import 'screens/onboarding/onboarding3_screen.dart';
import 'screens/auth/signin_phone_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/home/home_tabs.dart';
import 'screens/doctors/doctor_profile_screen.dart';
import 'screens/doctors/doctor_dashboard_screen.dart';
import 'screens/appointments/book_appointment_screen.dart';
import 'screens/appointments/booking_confirmation_screen.dart';
import 'package:appointment_app/screens/appointments/reschedule_appointment_screen.dart';
import 'services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize data service (register adapters and open boxes)
  await DataService.init();

  await NotificationService.init();

  // Load seed data on first launch
  await SeedService.loadSeedData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointment App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/onboarding1': (context) => const Onboarding1Screen(),
        '/onboarding2': (context) => const Onboarding2Screen(),
        '/onboarding3': (context) => const Onboarding3Screen(),
        '/signin': (context) => const SignInPhoneScreen(),
        '/otp': (context) => const OtpScreen(),
        '/home': (context) => const HomeTabs(),
        '/doctor_profile': (context) => const DoctorProfileScreen(),
        '/doctor-dashboard': (context) => const DoctorDashboardScreen(),
        '/book_appointment': (context) => const BookAppointmentScreen(),
        '/booking_confirmation': (context) => const BookingConfirmationScreen(),
        '/reschedule_appointment': (context) {
          final appointmentId =
              ModalRoute.of(context)!.settings.arguments as String;
          return RescheduleAppointmentScreen(appointmentId: appointmentId);
        },
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
