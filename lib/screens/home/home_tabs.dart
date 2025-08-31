import 'package:flutter/material.dart';
import '../doctors/doctors_list_screen.dart';
import '../appointments/upcoming_appointments_screen.dart';
import '../appointments/missed_appointments_screen.dart';
import '../appointments/completed_appointments_screen.dart';
import 'account_screen.dart';

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const UpcomingAppointmentsScreen(),
    const MissedAppointmentsScreen(),
    const CompletedAppointmentsScreen(),
    const DoctorsListScreen(), // Real doctors screen
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.upcoming), label: 'Upcoming'),
          BottomNavigationBarItem(icon: Icon(Icons.cancel), label: 'Missed'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle), label: 'Completed'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
