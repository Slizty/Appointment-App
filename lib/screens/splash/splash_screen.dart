import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Check if user is already logged in
      if (AuthService.isLoggedIn()) {
        // Check user role and navigate to appropriate interface
        if (AuthService.isCurrentUserDoctor()) {
          Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding1');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Appointment App',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}